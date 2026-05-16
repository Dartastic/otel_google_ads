// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_google_ads/otel_google_ads.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_google_ads-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('googleads.search records customer + spend + impressions', () async {
    await tracedGoogleAds<String>(
      operation: 'googleads.search',
      invoke: () async => const GoogleAdsCallResult(
        value: 'ok',
        result: GoogleAdsResult(
          customerId: '1234567890',
          loginCustomerId: '9876543210',
          campaignId: 'c1',
          campaignChannel: 'PERFORMANCE_MAX',
          campaignStatus: 'ENABLED',
          spendMicros: 12500000,
          currencyCode: 'USD',
          impressions: 50000,
          clicks: 1250,
          conversions: 42.5,
          searchImpressionShare: 0.62,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('google_ads googleads.search')!);
    expect(a['google_ads.customer.id'], '1234567890');
    expect(a['google_ads.login_customer.id'], '9876543210');
    expect(a['google_ads.campaign.channel'], 'PERFORMANCE_MAX');
    expect(a['google_ads.spend.micros'], 12500000);
    expect(a['google_ads.impressions'], 50000);
    expect(a['google_ads.conversions'], 42.5);
    expect(a['google_ads.search_impression_share'], 0.62);
  });

  test('partial_failures sets span error', () async {
    await tracedGoogleAds<String>(
      operation: 'campaign.mutate',
      invoke: () async => const GoogleAdsCallResult(
        value: 'ok',
        result: GoogleAdsResult(
          operationsCount: 25,
          partialFailures: true,
        ),
      ),
    );
    expect(
      spans.findSpanByName('google_ads campaign.mutate')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutGoogleAdsInstrumentationAsync(() async {
      await tracedGoogleAds<String>(
        operation: 'customer.list_accessible',
        invoke: () async => const GoogleAdsCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('google_ads '), isEmpty);
  });
}
