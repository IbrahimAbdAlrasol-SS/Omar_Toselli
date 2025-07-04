import 'package:Tosell/core/config/routes/app_router.dart';
import 'package:Tosell/core/widgets/Others/CustomAppBar.dart';
import 'package:Tosell/features/orders/data/models/Order.dart';
import 'package:Tosell/features/orders/presentation/providers/orders_provider.dart';
import 'package:Tosell/features/orders/presentation/widgets/order_card_item.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
class ShipmentDetailsScreen extends ConsumerStatefulWidget {
  final String shipmentCode;

  const ShipmentDetailsScreen({super.key, required this.shipmentCode});

  @override
  ConsumerState<ShipmentDetailsScreen> createState() =>
      _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends ConsumerState<ShipmentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: "طلبات الشحنة ${widget.shipmentCode}",
              showBackButton: true,
            ),
            // قائمة الطلبات
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GenericPagedListView<Order>(
                  itemBuilder: (context, order, index) => OrderCardItem(
                    order: order,
                    onTap: () {
                      // التنقل إلى تفاصيل الطلب
                      context.push(AppRoutes.orderDetails, extra: order.code);
                    },
                  ),
                  fetchPage: (page, filter) async {
                    // جلب الطلبات الخاصة بهذه الشحنة
                    return await ref
                        .read(ordersNotifierProvider.notifier)
                        .getOrdersByShipment(
                          widget.shipmentCode,
                          page,
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
