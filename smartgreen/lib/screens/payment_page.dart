// lib/screens/payment_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';
import 'order_confirmation_page.dart';
import '../widgets/custom_button.dart';
import 'address_selection_page.dart';
import '../globals.dart'; // Certifique-se de que este arquivo existe e getUserData está definido
import '../theme/app_colors.dart'; // Importar AppColors para usar as cores customizadas

class PaymentPage
    extends
        StatefulWidget {
  final Address selectedAddress;

  const PaymentPage({
    super.key,
    required this.selectedAddress,
  });

  @override
  State<
    PaymentPage
  >
  createState() =>
      _PaymentPageState();
}

class _PaymentPageState
    extends
        State<
          PaymentPage
        > {
  String _paymentMethod =
      'PIX';
  late Address _selectedAddress;
  bool _isLoading =
      false; // Estado para controlar o feedback de loading do botão

  @override
  void initState() {
    super.initState();
    _selectedAddress =
        widget.selectedAddress;
  }

  Future<
    void
  >
  _finalizarPedido() async {
    setState(
      () =>
          _isLoading =
              true,
    ); // Inicia o loading

    final uid =
        getUserData()?.id;
    if (uid ==
            null ||
        uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Sessão expirada. Faça login novamente.',
          ),
        ),
      );
      setState(
        () =>
            _isLoading =
                false,
      ); // Para o loading
      return;
    }

    final cart = Provider.of<
      CartService
    >(
      context,
      listen:
          false,
    );
    final orderService = OrderService(
      userId:
          uid,
    );

    final items =
        cart.items
            .map(
              (
                ci,
              ) => OrderItem(
                productId:
                    ci.product.id,
                quantity:
                    ci.quantity,
                unitPrice:
                    ci.product.precoUnt,
              ),
            )
            .toList();

    final order = Order(
      id:
          '',
      items:
          items,
      addressId:
          _selectedAddress.id,
      paymentMethod:
          _paymentMethod,
      total:
          cart.totalPrice,
      createdAt:
          DateTime.now(),
    );

    try {
      final orderId = await orderService.addOrder(
        order,
      );
      cart.clearCart();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (
                _,
              ) => OrderConfirmationPage(
                orderId:
                    orderId,
              ),
        ),
      );
    } catch (
      e
    ) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao finalizar pedido: $e',
          ),
        ),
      );
    } finally {
      setState(
        () =>
            _isLoading =
                false,
      ); // Finaliza o loading
    }
  }

  Future<
    void
  >
  _chooseAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (
              _,
            ) =>
                const AddressSelectionPage(),
      ),
    );
    if (!mounted) return;
    if (result
        is Address) {
      setState(
        () =>
            _selectedAddress =
                result,
      );
    }
  }

  Widget _buildPaymentOption(
    String method,
    String label,
    String iconPath,
  ) {
    final cs =
        Theme.of(
          context,
        ).colorScheme;
    return Card(
      color:
          _paymentMethod ==
                  method
              ? AppColors.surfaceAlt
              : cs.surface, // Destaca o selecionado
      elevation:
          _paymentMethod ==
                  method
              ? 3
              : 1, // Elevação maior para o selecionado
      margin: const EdgeInsets.symmetric(
        vertical:
            8,
      ),
      child: ListTile(
        leading: Image.asset(
          iconPath,
          width:
              40,
          height:
              40,
        ), // Ícone um pouco menor
        title: Text(
          label,
          style: TextStyle(
            color:
                cs.onSurface,
          ),
        ),
        trailing: Radio<
          String
        >(
          value:
              method,
          groupValue:
              _paymentMethod,
          onChanged:
              (
                value,
              ) => setState(
                () =>
                    _paymentMethod =
                        value!,
              ),
          activeColor:
              cs.primary, // Cor do rádio button ativo
        ),
        onTap:
            () => setState(
              () =>
                  _paymentMethod =
                      method,
            ),
      ),
    );
  }

  Widget _addressCard(
    Address a,
  ) {
    final tt =
        Theme.of(
          context,
        ).textTheme;
    final cs =
        Theme.of(
          context,
        ).colorScheme;

    final title =
        StringBuffer()
          ..write(
            a.street,
          )
          ..write(
            a.number.isNotEmpty
                ? ', ${a.number}'
                : '',
          );
    final line2 =
        StringBuffer()
          ..write(
            a.neighborhood.isNotEmpty
                ? '${a.neighborhood} • '
                : '',
          )
          ..write(
            a.city,
          )
          ..write(
            a.state.isNotEmpty
                ? '/${a.state}'
                : '',
          );
    final line3 =
        'CEP: ${a.cep}';
    final hasCompl =
        a.complement.trim().isNotEmpty;
    final hasRef =
        a.reference.trim().isNotEmpty;

    return Card(
      color:
          cs.surface,
      elevation:
          2,
      margin: const EdgeInsets.symmetric(
        vertical:
            8,
      ),
      child: InkWell(
        onTap:
            _chooseAddress, // tocar para escolher outro endereço
        borderRadius: BorderRadius.circular(
          12,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12,
          ), // Padding ajustado
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title.toString(),
                style: tt.titleSmall?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                  color:
                      cs.onSurface,
                ),
              ),
              const SizedBox(
                height:
                    4,
              ),
              Text(
                line2.toString(),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(
                    0.8,
                  ),
                ),
              ),
              Text(
                line3,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(
                    0.8,
                  ),
                ),
              ),
              if (hasCompl ||
                  hasRef)
                const SizedBox(
                  height:
                      4,
                ),
              if (hasCompl)
                Text(
                  'Complemento: ${a.complement}',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(
                      0.8,
                    ),
                  ),
                ),
              if (hasRef)
                Text(
                  'Referência: ${a.reference}',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(
                      0.8,
                    ),
                  ),
                ),
              const SizedBox(
                height:
                    8,
              ), // Aumentado o espaço
              Align(
                alignment:
                    Alignment.bottomRight,
                child: Text(
                  'Toque para escolher outro endereço',
                  style: tt.bodySmall?.copyWith(
                    color: cs.primary.withOpacity(
                      0.8,
                    ),
                    fontWeight:
                        FontWeight.w500,
                  ), // Destaca como ação
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para exibir um item do carrinho
  Widget _buildCartItemSummary(
    BuildContext context,
    CartItem item,
  ) {
    final cs =
        Theme.of(
          context,
        ).colorScheme;
    final tt =
        Theme.of(
          context,
        ).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical:
            4.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.quantity}x ${item.product.nome}',
              style: tt.bodyMedium!.copyWith(
                color: cs.onSurface.withOpacity(
                  0.9,
                ),
              ),
              maxLines:
                  1,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
          Text(
            'R\$ ${item.totalPrice.toStringAsFixed(2)}',
            style: tt.bodyMedium!.copyWith(
              color: cs.onSurface.withOpacity(
                0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final cs =
        Theme.of(
          context,
        ).colorScheme;
    final cart = Provider.of<
      CartService
    >(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pagamento',
        ),
        centerTitle:
            true,
        backgroundColor:
            cs.primary,
        foregroundColor:
            cs.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // --- Resumo do Pedido ---
                  Text(
                    'Resumo do Pedido:',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          cs.onSurface,
                    ),
                  ),
                  const SizedBox(
                    height:
                        8,
                  ),
                  Card(
                    color:
                        cs.surface,
                    elevation:
                        2,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ),
                      child: Column(
                        children: [
                          ...cart.items.map(
                            (
                              item,
                            ) => _buildCartItemSummary(
                              context,
                              item,
                            ),
                          ),
                          if (cart.items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical:
                                    8.0,
                              ),
                              child: Text(
                                'Seu carrinho está vazio.',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  fontStyle:
                                      FontStyle.italic,
                                  color: cs.onSurface.withOpacity(
                                    0.7,
                                  ),
                                ),
                                textAlign:
                                    TextAlign.center,
                              ),
                            ),
                          const Divider(
                            height:
                                24,
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal:',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      cs.onSurface,
                                ),
                              ),
                              Text(
                                'R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        24,
                  ),

                  // --- Endereço de Entrega ---
                  Text(
                    'Endereço de Entrega:',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          cs.onSurface,
                    ),
                  ),
                  _addressCard(
                    _selectedAddress,
                  ),
                  const SizedBox(
                    height:
                        24,
                  ),

                  // --- Forma de Pagamento ---
                  Text(
                    'Escolha a forma de pagamento:',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          cs.onSurface,
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  _buildPaymentOption(
                    'PIX',
                    'PIX',
                    'assets/icons/pix.png',
                  ),
                  _buildPaymentOption(
                    'Cartão',
                    'Cartão de Crédito',
                    'assets/icons/cartao_credito.png',
                  ),
                  // Adicionar o Boleto, mas com foco na estilização, não na lógica
                  _buildPaymentOption(
                    'Boleto',
                    'Boleto Bancário',
                    'assets/icons/boleto.png',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: SafeArea(
              top:
                  false,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total do Pedido: R\$ ${cart.totalPrice.toStringAsFixed(2)}', // Total final
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          cs.onSurface,
                    ),
                    textAlign:
                        TextAlign.center,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  CustomButton(
                    label:
                        _isLoading
                            ? 'Processando...'
                            : 'Finalizar Pedido',
                    icon:
                        Icons.check_circle,
                    backgroundColor:
                        cs.primary,
                    textColor:
                        cs.onPrimary,
                    onPressed:
                        _isLoading ||
                                cart.items.isEmpty
                            ? null
                            : _finalizarPedido, // Desabilita se estiver carregando ou carrinho vazio
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
