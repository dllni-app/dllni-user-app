import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:dllni_user_app/features/orders/data/models/orders_api_models.dart';
import 'package:dllni_user_app/features/orders/data/models/merchant_cart_models.dart';
import 'package:dllni_user_app/features/orders/domain/repository/orders_repo.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/place_store_order_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/place_restaurant_order_use_case.dart';
import 'package:dllni_user_app/features/orders/view/manager/bloc/orders_bloc.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_orders_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_cleaning_orders_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/cancel_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_restaurant_cart_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_store_cart_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/update_cart_item_quantity_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/update_store_cart_item_quantity_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/delete_cart_item_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/delete_store_cart_item_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/check_restaurant_coupon_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/checkout_preview_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/fetch_supermarket_cart_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/remove_supermarket_cart_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/get_single_supermarket_cart_use_case.dart';

class _FakeOrdersRepo implements OrdersRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFetchOrdersUseCase implements FetchOrdersUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFetchCleaningOrdersUseCase implements FetchCleaningOrdersUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCancelCleaningOrderUseCase implements CancelCleaningOrderUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFetchRestaurantCartUseCase implements FetchRestaurantCartUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFetchStoreCartUseCase implements FetchStoreCartUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUpdateCartItemQuantityUseCase implements UpdateCartItemQuantityUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUpdateStoreCartItemQuantityUseCase implements UpdateStoreCartItemQuantityUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeleteCartItemUseCase implements DeleteCartItemUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeleteStoreCartItemUseCase implements DeleteStoreCartItemUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCheckRestaurantCouponUseCase implements CheckRestaurantCouponUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePreviewStoreCheckoutUseCase implements PreviewStoreCheckoutUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFetchSupermarketCartUseCase implements FetchSupermarketCartUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRemoveSupermarketCartUseCase implements RemoveSupermarketCartUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetSingleSupermarketCartUseCase implements GetSingleSupermarketCartUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InterceptStore extends PlaceStoreOrderUseCase {
  _InterceptStore() : super(ordersRepo: _FakeOrdersRepo());
  final pending = <Completer<Either<Failure, PlaceRestaurantOrderModel>>>[];
  @override
  DataResponse<PlaceRestaurantOrderModel> call(PlaceStoreOrderParams params) {
    final c = Completer<Either<Failure, PlaceRestaurantOrderModel>>();
    pending.add(c);
    return c.future;
  }
  void release() {
    for (final c in pending) {
      if (!c.isCompleted) c.complete(left(ServerFailure(message: 'QA intercepted', statusCode: 503)));
    }
  }
}

class _InterceptRestaurant extends PlaceRestaurantOrderUseCase {
  _InterceptRestaurant() : super(ordersRepo: _FakeOrdersRepo());
  final pending = <Completer<Either<Failure, PlaceRestaurantOrderModel>>>[];
  @override
  DataResponse<PlaceRestaurantOrderModel> call(PlaceRestaurantOrderParams params) {
    final c = Completer<Either<Failure, PlaceRestaurantOrderModel>>();
    pending.add(c);
    return c.future;
  }
  void release() {
    for (final c in pending) {
      if (!c.isCompleted) c.complete(left(ServerFailure(message: 'QA intercepted', statusCode: 503)));
    }
  }
}

class _InterceptPreviewStore extends PreviewStoreCheckoutUseCase {
  _InterceptPreviewStore() : super(ordersRepo: _FakeOrdersRepo());
  final pending = <Completer<Either<Failure, CheckoutPreviewModel>>>[];
  final params = <CheckoutPreviewParams>[];
  @override
  DataResponse<CheckoutPreviewModel> call(CheckoutPreviewParams p) {
    params.add(p);
    final c = Completer<Either<Failure, CheckoutPreviewModel>>();
    pending.add(c);
    return c.future;
  }
  void completeAt(int index, double total) {
    pending[index].complete(right(CheckoutPreviewModel(
      data: CheckoutPreviewDataModel(
        amounts: CheckoutPreviewAmountsModel(total: total),
      ),
    )));
  }
  void failAt(int index, String message) {
    pending[index].complete(left(ServerFailure(message: message, statusCode: 503)));
  }
}

OrdersBloc _bloc(_InterceptRestaurant restaurant, _InterceptStore store, {PreviewStoreCheckoutUseCase? preview}) =>
  OrdersBloc(
    _FakeFetchOrdersUseCase(),
    _FakeFetchCleaningOrdersUseCase(),
    _FakeCancelCleaningOrderUseCase(),
    _FakeFetchRestaurantCartUseCase(),
    _FakeFetchStoreCartUseCase(),
    _FakeUpdateCartItemQuantityUseCase(),
    _FakeUpdateStoreCartItemQuantityUseCase(),
    _FakeDeleteCartItemUseCase(),
    _FakeDeleteStoreCartItemUseCase(),
    _FakeCheckRestaurantCouponUseCase(),
    restaurant,
    store,
    preview ?? _FakePreviewStoreCheckoutUseCase(),
    _FakeFetchSupermarketCartUseCase(),
    _FakeRemoveSupermarketCartUseCase(),
    _FakeGetSingleSupermarketCartUseCase()
  );

void main() {
  test('Supermarket rapid double-submit must invoke checkout once (no HTTP)', () async {
    final store = _InterceptStore();
    final restaurant = _InterceptRestaurant();
    final bloc = _bloc(restaurant, store);
    bloc.add(CartFulfillmentTypeChangedEvent(fulfillmentType: 'pickup'));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(bloc.state.selectedFulfillmentType, 'pickup');
    bloc.add(PlaceStoreOrderEvent(cartId: 777));
    bloc.add(PlaceStoreOrderEvent(cartId: 777));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final calls = store.pending.length;
    store.release();
    await bloc.close();
    expect(calls, 1, reason: 'Duplicate user actions must not invoke two order placement requests.');
  });

  test('Restaurant rapid double-submit must invoke checkout once (no HTTP)', () async {
    final store = _InterceptStore();
    final restaurant = _InterceptRestaurant();
    final bloc = _bloc(restaurant, store);
    bloc.add(CartFulfillmentTypeChangedEvent(fulfillmentType: 'pickup'));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(bloc.state.selectedFulfillmentType, 'pickup');
    bloc.add(PlaceRestaurantOrderEvent(cartId: 778));
    bloc.add(PlaceRestaurantOrderEvent(cartId: 778));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final calls = restaurant.pending.length;
    restaurant.release();
    await bloc.close();
    expect(calls, 1, reason: 'Duplicate user actions must not invoke two order placement requests.');
  });

  test('Checkout preview must ignore older slower response after newer request', () async {
    final preview = _InterceptPreviewStore();
    final bloc = _bloc(_InterceptRestaurant(), _InterceptStore(), preview: preview);
    bloc.add(CartFulfillmentTypeChangedEvent(fulfillmentType: 'pickup'));
    bloc.add(CartNoteChangedEvent(note: 'old'));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    bloc.add(PreviewStoreCheckoutEvent(cartId: 779));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    bloc.add(CartNoteChangedEvent(note: 'new'));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    bloc.add(PreviewStoreCheckoutEvent(cartId: 779));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(preview.params.length, 2);
    expect(preview.params[0].note, 'old');
    expect(preview.params[1].note, 'new');
    preview.completeAt(1, 80);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(bloc.state.storeCheckoutPreview?.amounts?.total, 80);
    preview.completeAt(0, 100);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final finalTotal = bloc.state.storeCheckoutPreview?.amounts?.total;
    await bloc.close();
    expect(finalTotal, 80, reason: 'Late response for old cart note must not replace the newest preview.');
  });

  test('Retry preview success must survive late failure from timed-out attempt', () async {
    final preview = _InterceptPreviewStore();
    final bloc = _bloc(_InterceptRestaurant(), _InterceptStore(), preview: preview);
    bloc.add(CartFulfillmentTypeChangedEvent(fulfillmentType: 'pickup'));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    bloc.add(PreviewStoreCheckoutEvent(cartId: 780));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    bloc.add(PreviewStoreCheckoutEvent(cartId: 780));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(preview.pending.length, 2);
    preview.completeAt(1, 80);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(bloc.state.storeCheckoutPreview?.amounts?.total, 80);
    preview.failAt(0, 'Old timeout after successful retry');
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final error = bloc.state.storeCheckoutPreviewError;
    await bloc.close();
    expect(error, isNull, reason: 'A stale failed attempt must not turn a successful retry into an error.');
  });
}
