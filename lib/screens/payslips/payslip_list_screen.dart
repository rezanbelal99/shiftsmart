import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shiftsmart/models/payslip.dart';
import 'package:shiftsmart/store/app_state.dart';
import 'package:shiftsmart/store/actions/payslip_actions.dart';
import 'package:flutter_redux/flutter_redux.dart';

class PayslipListScreen extends StatelessWidget {
  const PayslipListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Payslip>>(
      converter: (store) => store.state.payslips,
      builder: (context, payslips) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Payslips'),
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body: payslips.isEmpty
              ? Center(
                  child: Text('No payslips found.',
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView.builder(
                  itemCount: payslips.length,
                  itemBuilder: (context, index) {
                    final payslip = payslips[index];
                    return Dismissible(
                      key: Key(payslip.employer + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        StoreProvider.of<AppState>(context).dispatch(DeletePayslipAction(index));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payslip deleted')),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          payslip.employer,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Net Pay: ${payslip.netPay.toStringAsFixed(2)} kr\nDate: ${payslip.paymentDate}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        isThreeLine: true,
                        tileColor: Colors.grey[850],
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        leading: Icon(Icons.receipt, color: Colors.white),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}