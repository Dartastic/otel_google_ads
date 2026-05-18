// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_google_ads_suppression.dart';

const _tracerName = 'dartastic_otel_libs_google_ads';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class GoogleAdsResult {
  const GoogleAdsResult({
    this.customerId,
    this.loginCustomerId,
    this.campaignId,
    this.campaignName,
    this.campaignChannel,
    this.campaignStatus,
    this.adGroupId,
    this.spendMicros,
    this.currencyCode,
    this.impressions,
    this.clicks,
    this.conversions,
    this.conversionValueMicros,
    this.searchImpressionShare,
    this.operationsCount,
    this.partialFailures,
    this.statusCode,
  });

  /// Account whose data is being touched (10-digit CID).
  final String? customerId;

  /// MCC/manager account when calling on behalf of [customerId].
  final String? loginCustomerId;

  final String? campaignId;
  final String? campaignName;

  /// `SEARCH` / `DISPLAY` / `SHOPPING` / `VIDEO` / `PERFORMANCE_MAX` /
  /// `DEMAND_GEN` / `MULTI_CHANNEL` / `LOCAL` / `SMART`.
  final String? campaignChannel;

  /// `ENABLED` / `PAUSED` / `REMOVED`.
  final String? campaignStatus;

  final String? adGroupId;

  /// Spend in micros of the account currency — Google's convention
  /// (1_000_000 micros = 1 currency unit).
  final int? spendMicros;

  final String? currencyCode;
  final int? impressions;
  final int? clicks;
  final double? conversions;
  final int? conversionValueMicros;

  /// Search impression share (0.0–1.0). Useful for auction-pressure
  /// budgeting.
  final double? searchImpressionShare;

  /// Number of mutate operations sent in a batch request.
  final int? operationsCount;

  /// `true` if Google Ads returned partial_failure_error in a mutate.
  final bool? partialFailures;

  final int? statusCode;
}

class GoogleAdsCallResult<T> {
  const GoogleAdsCallResult({required this.value, this.result});
  final T value;
  final GoogleAdsResult? result;
}

/// Wraps a Google Ads API call in a CLIENT span. [operation] is one
/// of `googleads.search`, `googleads.searchStream`, `campaign.mutate`,
/// `adgroup.mutate`, `ad.mutate`, `conversion_upload`,
/// `customer.list_accessible`, `keyword_plan.run`.
Future<T> tracedGoogleAds<T>({
  required String operation,
  required Future<GoogleAdsCallResult<T>> Function() invoke,
}) async {
  if (googleAdsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'google_ads',
    'rpc.method': operation,
    'google_ads.operation': operation,
  };

  final span = _tracer().startSpan(
    'google_ads $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.customerId != null) {
        extras.add(OTel.attributeString(
          'google_ads.customer.id',
          r.result!.customerId!,
        ));
      }
      if (r.result!.loginCustomerId != null) {
        extras.add(OTel.attributeString(
          'google_ads.login_customer.id',
          r.result!.loginCustomerId!,
        ));
      }
      if (r.result!.campaignId != null) {
        extras.add(OTel.attributeString(
          'google_ads.campaign.id',
          r.result!.campaignId!,
        ));
      }
      if (r.result!.campaignName != null) {
        extras.add(OTel.attributeString(
          'google_ads.campaign.name',
          r.result!.campaignName!,
        ));
      }
      if (r.result!.campaignChannel != null) {
        extras.add(OTel.attributeString(
          'google_ads.campaign.channel',
          r.result!.campaignChannel!,
        ));
      }
      if (r.result!.campaignStatus != null) {
        extras.add(OTel.attributeString(
          'google_ads.campaign.status',
          r.result!.campaignStatus!,
        ));
      }
      if (r.result!.adGroupId != null) {
        extras.add(OTel.attributeString(
          'google_ads.ad_group.id',
          r.result!.adGroupId!,
        ));
      }
      if (r.result!.spendMicros != null) {
        extras.add(OTel.attributeInt(
          'google_ads.spend.micros',
          r.result!.spendMicros!,
        ));
      }
      if (r.result!.currencyCode != null) {
        extras.add(OTel.attributeString(
          'google_ads.currency.code',
          r.result!.currencyCode!,
        ));
      }
      if (r.result!.impressions != null) {
        extras.add(OTel.attributeInt(
          'google_ads.impressions',
          r.result!.impressions!,
        ));
      }
      if (r.result!.clicks != null) {
        extras.add(OTel.attributeInt(
          'google_ads.clicks',
          r.result!.clicks!,
        ));
      }
      if (r.result!.conversions != null) {
        extras.add(OTel.attributeDouble(
          'google_ads.conversions',
          r.result!.conversions!,
        ));
      }
      if (r.result!.conversionValueMicros != null) {
        extras.add(OTel.attributeInt(
          'google_ads.conversion_value.micros',
          r.result!.conversionValueMicros!,
        ));
      }
      if (r.result!.searchImpressionShare != null) {
        extras.add(OTel.attributeDouble(
          'google_ads.search_impression_share',
          r.result!.searchImpressionShare!,
        ));
      }
      if (r.result!.operationsCount != null) {
        extras.add(OTel.attributeInt(
          'google_ads.operations.count',
          r.result!.operationsCount!,
        ));
      }
      if (r.result!.partialFailures != null) {
        extras.add(OTel.attributeBool(
          'google_ads.partial_failures',
          r.result!.partialFailures!,
        ));
        if (r.result!.partialFailures!) {
          span.setStatus(
            SpanStatusCode.Error,
            'Google Ads partial_failure_error',
          );
        }
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Google Ads HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
