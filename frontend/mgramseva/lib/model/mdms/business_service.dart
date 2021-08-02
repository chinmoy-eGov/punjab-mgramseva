import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/mdms/tax_head_master.dart';

part 'business_service.g.dart';


@JsonSerializable()
class BillingService {

  @JsonKey(name: "BusinessService")
  List<BusinessService>? businessServiceList;

  @JsonKey(name: "TaxHeadMaster")
  List<TaxHeadMaster>? taxHeadMasterList;

  BillingService();

  factory BillingService.fromJson(Map<String, dynamic> json) =>
      _$BillingServiceFromJson(json);

  Map<String, dynamic> toJson() => _$BillingServiceToJson(this);
}

@JsonSerializable()
class BusinessService {

  @JsonKey(name: "businessService")
  String? businessService;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "collectionModesNotAllowed")
  List<String>? collectionModesNotAllowed;

  @JsonKey(name: "partPaymentAllowed")
  bool? partPaymentAllowed;

  @JsonKey(name: "isAdvanceAllowed")
  bool? isAdvanceAllowed;

  @JsonKey(name: "isVoucherCreationEnabled")
  bool? isVoucherCreationEnabled;

  @JsonKey(name: "isActive")
  bool? isActive;

  @JsonKey(name: "type")
  String? type;

  BusinessService();

  factory BusinessService.fromJson(Map<String, dynamic> json) =>
      _$BusinessServiceFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessServiceToJson(this);
}


