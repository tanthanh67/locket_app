import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locket_app/modules/feed/presentation/components/bottom_nav.dart';
import 'package:locket_app/modules/feed/presentation/components/feed_top_bar.dart';

void main() {
  testWidgets('Feed controls expose shared top bar and camera action', (
    tester,
  ) async {
    var cameraTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const FeedTopBar(),
              BottomNav(onCameraTap: () => cameraTapped = true),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);

    await tester.tap(find.byType(InkWell).last);
    await tester.pump();

    expect(cameraTapped, isTrue);
  });
}
