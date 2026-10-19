-- MotionFit iOS 1.6.6: BigQuery Standard SQL template. Not executed.
-- Replace YOUR_PROJECT.analytics_PROPERTY_ID with the linked GA4 dataset.
-- Bind @ios_stream_id as STRING after confirming the MotionFit iOS stream.
-- Dates use GA property event_date / daily table boundaries, not an assumed UTC/KST boundary.
-- Align the AdMob account timezone before comparing daily numbers.
-- Only daily tables are selected; do not UNION intraday tables over them.
-- SDK source identity is primary. Custom parameters are audited separately.
-- Schema: https://support.google.com/analytics/answer/7029846?hl=en

CREATE TEMP FUNCTION EventParam(params ANY TYPE, param_key STRING) AS (
  (SELECT COALESCE(p.value.string_value, CAST(p.value.int_value AS STRING))
   FROM UNNEST(params) AS p WHERE p.key = param_key LIMIT 1)
);

CREATE TEMP TABLE period_events AS
SELECT
  event_date,
  event_timestamp,
  event_name,
  user_pseudo_id,
  stream_id,
  platform,
  app_info.id AS bundle_id,
  app_info.version AS sdk_app_version,
  EventParam(event_params, 'platform') AS custom_platform,
  EventParam(event_params, 'app_version') AS custom_app_version,
  EventParam(event_params, 'build_number') AS build_number,
  EventParam(event_params, 'analytics_revision') AS analytics_revision,
  EventParam(event_params, 'ga_session_id') AS ga_session_id,
  EventParam(event_params, 'workout_session_id') AS workout_session_id,
  EventParam(event_params, 'ad_format') AS ad_format,
  COALESCE(EventParam(event_params, 'ad_placement'),
           EventParam(event_params, 'placement')) AS placement,
  EventParam(event_params, 'ad_unit_id') AS ad_unit_id,
  EventParam(event_params, 'request_id') AS request_id,
  EventParam(event_params, 'opportunity_id') AS opportunity_id,
  EventParam(event_params, 'skip_reason') AS skip_reason,
  EventParam(event_params, 'failure_stage') AS failure_stage,
  EventParam(event_params, 'error_code') AS error_code,
  EventParam(event_params, 'error_domain') AS error_domain,
  EventParam(event_params, 'debug_mode') AS debug_mode
FROM `YOUR_PROJECT.analytics_PROPERTY_ID.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20260919' AND '20261016';

-- Result 1: Show the actual platform/app/version distribution before filtering.
-- This is event-time version attribution, not users ever seen on a version.
SELECT
  platform, stream_id, bundle_id, sdk_app_version,
  COALESCE(build_number, 'unrecorded') AS build_number,
  COUNT(*) AS events,
  COUNT(DISTINCT user_pseudo_id) AS identified_users
FROM period_events
GROUP BY 1, 2, 3, 4, 5
ORDER BY events DESC;

CREATE TEMP TABLE ios166_events AS
SELECT *,
  CASE
    WHEN (custom_platform IS NOT NULL AND LOWER(custom_platform) != 'ios')
      OR (custom_app_version IS NOT NULL AND custom_app_version != sdk_app_version)
      THEN 'custom_context_conflict'
    WHEN build_number = '66' THEN 'build_66'
    WHEN build_number IS NULL THEN 'build_unrecorded'
    ELSE 'other_build'
  END AS identity_group
FROM period_events
WHERE UPPER(platform) = 'IOS'
  AND stream_id = @ios_stream_id
  AND bundle_id = 'fit.motionfit.app'
  AND sdk_app_version = '1.6.6';

-- Result 2: iOS 1.6.6 event names split by build and context consistency.
-- Do not require build_number=66 for automatic events: many lack that parameter.
-- debug_mode=NULL means unrecorded, not confirmed production traffic.
-- A zero custom load/show count may mean not instrumented, not zero SDK outcomes.
SELECT
  identity_group,
  COALESCE(build_number, 'unrecorded') AS build_number,
  COALESCE(analytics_revision, 'unrecorded') AS analytics_revision,
  COALESCE(debug_mode, 'unrecorded') AS debug_mode,
  event_name,
  COUNT(*) AS events,
  COUNT(DISTINCT user_pseudo_id) AS identified_users
FROM ios166_events
GROUP BY 1, 2, 3, 4, 5
ORDER BY identity_group, events DESC;

-- Result 3: Ad diagnostics without merging unrelated event schemas into a funnel.
-- Do not join different users by ga_session_id alone.
-- Do not divide request events by show events across differing placements/formats.
SELECT
  identity_group,
  event_name,
  COALESCE(ad_format, 'unrecorded') AS ad_format,
  COALESCE(placement, 'unrecorded') AS placement,
  COALESCE(ad_unit_id, 'unrecorded') AS ad_unit_id,
  skip_reason,
  failure_stage,
  error_code,
  error_domain,
  COUNT(*) AS events,
  COUNT(DISTINCT user_pseudo_id) AS identified_users
FROM ios166_events
WHERE REGEXP_CONTAINS(event_name, r'^(mf2_ad|mf2_ads|ad_|ads_|interstitial_|native_ad_|consent_|ump_)')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
ORDER BY identity_group, event_name, events DESC;

-- Result 4: Bounded timeline for individual-request investigation.
-- request_id/opportunity_id are expected NULL in the audited old Flutter source.
-- Do not infer an exact request->impression join from timestamp proximity alone.
-- This sample is for diagnosis, not whole-period aggregate calculations.
SELECT
  event_date, TIMESTAMP_MICROS(event_timestamp) AS event_time_utc,
  user_pseudo_id, ga_session_id, identity_group,
  build_number, analytics_revision, debug_mode,
  event_name, ad_format, placement, ad_unit_id,
  workout_session_id, request_id, opportunity_id,
  skip_reason, failure_stage, error_code, error_domain
FROM ios166_events
WHERE REGEXP_CONTAINS(event_name, r'^(mf2_ad|mf2_ads|ad_|ads_|interstitial_|native_ad_|consent_|ump_|mf2_workout_)')
ORDER BY user_pseudo_id, ga_session_id, event_timestamp
LIMIT 10000;
