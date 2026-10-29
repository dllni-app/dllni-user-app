import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/orders/view/manager/bloc/orders_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('silent cleaning poll cannot cancel an unfinished initial fetch', () async {
    final requests = StreamController<FetchOrdersEvent>();
    final initialCompleted = Completer<void>();
    final received = <FetchOrdersEvent>[];
    final subscription = paginationEventTransformer<FetchOrdersEvent>()(
      requests.stream,
      (event) async* {
        if (event.isReload) await initialCompleted.future;
        yield event;
      },
    ).listen(received.add);

    requests.add(FetchOrdersEvent(isReload: true));
    await Future<void>.delayed(Duration.zero);
    // This is how the list timer now dispatches its background refresh.
    requests.add(FetchOrdersEvent(silentRefresh: true));
    await Future<void>.delayed(Duration.zero);
    initialCompleted.complete();
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(1));
    expect(received.single.isReload, isTrue);
    await subscription.cancel();
    await requests.close();
  });
}
