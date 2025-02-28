import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/model/demand/update_demand_list.dart';
import 'package:mgramseva/repository/bill_generation_details_repo.dart';
import 'package:mgramseva/repository/billing_service_repo.dart';
import 'package:mgramseva/repository/search_connection_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import 'common_provider.dart';
import 'fetch_bill_provider.dart';

class HouseHoldProvider with ChangeNotifier {
  late GlobalKey<FormState> formKey;
  WaterConnection? waterConnection;
  UpdateDemandList? updateDemandList;
  bool isfirstdemand = false;
  var streamController = StreamController.broadcast();
  var isVisible = false;

  Future<void> checkMeterDemand(
      BillList data, WaterConnection waterConnection) async {
    if (data.bill!.isNotEmpty) {
      try {
        var res = await BillGenerateRepository().searchMeteredDemand({
          "tenantId": data.bill!.first.tenantId,
          "connectionNos": data.bill!.first.consumerCode
        });
        if (res.meterReadings!.isNotEmpty) {
          data.bill!.first.meterReadings = res.meterReadings;
        }
        if (data.bill!.first.billDetails != null) {
          data.bill!.first.billDetails!
              .sort((a, b) => b.toPeriod!.compareTo(a.toPeriod!));
        }
        data.bill!.first.waterConnection = waterConnection;
        streamController.add(data);
      } catch (e, s) {
        streamController.addError('error');
        ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      }
    } else {
      streamController.add(data);
    }
  }

  Future<void> fetchDemand(data, List<UpdateDemands>? demandList,
      [String? id, String? status]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    try {
      if (data == null) {
        var res = await SearchConnectionRepository().getconnection({
          "tenantId": commonProvider.userDetails!.selectedtenant!.code,
          ...{'connectionNumber': id},
        });
        if (res != null &&
            res.waterConnection != null &&
            res.waterConnection!.isNotEmpty) {
          data = res.waterConnection!.first;
        }
      }
      waterConnection = data;

      waterConnection?.fetchBill = await Provider.of<FetchBillProvider>(
              navigatorKey.currentContext!,
              listen: false)
          .fetchBill(waterConnection, navigatorKey.currentContext!);

      var mdms = await CommonProvider.getMdmsBillingService(
          commonProvider.userDetails!.selectedtenant?.code.toString() ??
              commonProvider.userDetails!.userRequest!.tenantId.toString());
      if (mdms.mdmsRes?.billingService?.taxHeadMasterList != null &&
          mdms.mdmsRes!.billingService!.taxHeadMasterList!.isNotEmpty) {
        waterConnection?.mdmsData = mdms;
      } else {
        var mdmsData = await CommonProvider.getMdmsBillingService(
            commonProvider.userDetails!.selectedtenant?.code.toString() ??
                commonProvider.userDetails!.userRequest!.tenantId.toString());
        waterConnection?.mdmsData = mdmsData;
      }

      if (status != Constants.CONNECTION_STATUS.first) {
        if (demandList == null) {
          var demand = await BillingServiceRepository().fetchUpdateDemand({
            "tenantId": data.tenantId,
            "consumerCodes": data.connectionNo.toString(),
            "isGetPenaltyEstimate": "true"
          }, {
            "GetBillCriteria": {
              "tenantId": data.tenantId,
              "billId": null,
              "isGetPenaltyEstimate": true,
              "consumerCodes": [data.connectionNo.toString()]
            }
          });

          demandList = demand.demands;
          updateDemandList?.totalApplicablePenalty =
              demand.totalApplicablePenalty;
          demandList?.forEach((e) {
            e.totalApplicablePenalty = demand.totalApplicablePenalty;
          });

          if (demandList != null && demandList.length > 0) {
            demandList.sort((a, b) => b
                .demandDetails!.first.auditDetails!.createdTime!
                .compareTo(a.demandDetails!.first.auditDetails!.createdTime!));
          }
        }
        demandList = demandList
            ?.where((element) => element.status != 'CANCELLED')
            .toList();
        waterConnection?.demands = demandList;
        updateDemandList?.demands = demandList;
      } else {}

      await BillingServiceRepository().fetchdDemand({
        "tenantId": data.tenantId,
        "consumerCode": data.connectionNo.toString(),
        "businessService": "WS",
        // "status": "ACTIVE"
      }).then((value) {
        value.demands = value.demands
            ?.where((element) => element.status != 'CANCELLED')
            .toList();

        if (value.demands!.length > 0) {
          value.demands!.sort((a, b) => b
              .demandDetails!.first.auditDetails!.createdTime!
              .compareTo(a.demandDetails!.first.auditDetails!.createdTime!));
          if (value.demands?.isEmpty == true) {
            isfirstdemand = false;
          } else if (value.demands?.length == 1 &&
              value.demands?.first.consumerType == 'waterConnection-arrears') {
            isfirstdemand = false;
          } else if (value.demands?.length == 1 &&
                  value.demands?.first.consumerType ==
                      'waterConnection-advance' &&
                  value.demands?.first.demandDetails?.first.taxHeadMasterCode ==
                      'WS_ADVANCE_CARRYFORWARD' &&
                  ((waterConnection?.fetchBill?.bill ?? []).length == 0) ||
              (waterConnection?.fetchBill?.bill?.first.totalAmount ?? 0) < 0) {
            isfirstdemand = false;
          } else {
            isfirstdemand = true;
          }
          streamController.add(value);

          // fetchBill(data);
        } else {
          DemandList demandList = new DemandList();
          demandList.demands = [];
          streamController.add(demandList);
        }
      });
    } catch (e, s) {
      streamController.addError('error');
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
    }
  }

  dispose() {
    streamController.close();
    super.dispose();
  }

  void callNotifyer() {
    notifyListeners();
  }

  onTapOfShow() {
    isVisible = !isVisible;
    notifyListeners();
  }
}
