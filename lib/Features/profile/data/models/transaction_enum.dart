import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TransactionEnum {
  String? title;
  Color? titleColor;

  String? screenTitle;
  Color? screenTitleColor;

  String? subTitle;
  SvgPicture? icon;

  Color? color;

  int? value;

  TransactionEnum({
    this.title,
    this.titleColor,
    this.subTitle,
    this.screenTitle,
    this.screenTitleColor,
    this.icon,
    this.color,
    this.value,
  });
}

var transactionStates = [
  //? index = 0
  TransactionEnum(
    title: 'تمت المعاملة',
    subTitle: 'تم تسليم المنتج واستلام المبلغ من العميل وتحويله إليك',
    titleColor: const Color(0xFF005200),
    screenTitle: 'مستلم',
    color: const Color(0xFFE8FCF5),
    icon: SvgPicture.asset(
      'assets/svg/CheckSquare.svg',
      color: const Color(0xFF8CD98C),
    ),
    screenTitleColor: const Color(0XFF0C6E4C),
    value: 0,
  ),

  //? index = 1
  TransactionEnum(
    title: 'تم إرجاع المعاملة',
    subTitle:
        'تم تسليم المنتج للعميل ولكن العميل لم يستلمه ويتم إرجاع منتجك إليك',
    titleColor: const Color(0xFF520000),
    screenTitle: 'مرتجع',
    color: const Color(0xFFFFF5F5),
    icon: SvgPicture.asset(
      'assets/svg/X.svg',
      color: const Color(0xFFE96363),
    ),
    screenTitleColor: const Color(0XFF520000),
    value: 1,
  ),

  //? index = 2
  TransactionEnum(
    title: 'معاملة مستحقة',
    titleColor: const Color(0xFF524100),
    subTitle:
        'استلم العميل منتجك وتم استلام المبلغ من قبل الشركة في انتظار تحويل المبلغ إليك',
    icon: SvgPicture.asset(
      'assets/svg/coines.svg',
      color: const Color(0xFFFFE500),
    ),
    screenTitle: 'مستحقة',
    screenTitleColor: const Color(0XFF524100),
    color: const Color(0xFFFFFAE5),
    value: 2,
  ),
];

// ignore: unused_element