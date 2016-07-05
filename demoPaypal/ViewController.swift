//
//  ViewController.swift
//  demoPaypal
//
//  Created by Atal Bansal on 05/07/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit
enum PaymentStatuses {
	case PAYMENTSTATUS_SUCCESS,
	PAYMENTSTATUS_FAILED,
	PAYMENTSTATUS_CANCELED
}

class ViewController: UIViewController,PayPalPaymentDelegate {
	
	let y:CGFloat  = 2.0
	let preapprovalField:UITextField = UITextField()
	var status:PaymentStatuses = PaymentStatuses.PAYMENTSTATUS_SUCCESS
	override func viewDidLoad() {
		super.viewDidLoad()
//[self addLabelWithText:@"Parallel Payment" andButtonWithType:BUTTON_294x43 withAction:@selector(parallelPayment)];
		addLabelWithText("Parallel Payment", type: BUTTON_294x43, action: Selector(parallelPayment()))
		// Do any additional setup after loading the view, typically from a nib.
	}


	func addLabelWithText(text:NSString,type:PayPalButtonType,action:Selector){
		let size: CGSize = text.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
		let button  = PayPal.getPayPalInst().getPayButtonWithTarget(self, andAction: action, andButtonType: type)
		var frame = button.frame
		frame.origin.x = round((self.view.frame.size.width -  button.frame.size.width) / 2)
		frame.origin.y = round(y + size.height)
		button.frame = frame
		self.view .addSubview(button)
		
		let label = UILabel.init(frame: CGRectMake(frame.origin.x, y, size.width, size.height))
		label.font = UIFont.systemFontOfSize(14.0)
		label.text = text as String
		label.backgroundColor = UIColor.clearColor()
		self.view.addSubview(label)
		//	y += size.height + frame.size.height + SPACING;
		
	}
	func parallelPayment(){
		preapprovalField.resignFirstResponder()
		PayPal.getPayPalInst().shippingEnabled = true
		PayPal.getPayPalInst().dynamicAmountUpdateEnabled = true
		PayPal.getPayPalInst().feePayer = FEEPAYER_EACHRECEIVER
		let payment:PayPalAdvancedPayment = PayPalAdvancedPayment()
		payment.paymentCurrency = "USD"
		payment.memo = "A Note applied to all recipients"
		payment.receiverPaymentDetails = NSMutableArray()
		let receiver1 :String = "First Receiver"
		let receiver2 :String = "Second Receiver"
		let receiver3 :String = "Third Receiver"
		let array: NSArray? = NSArray(objects: receiver1,receiver2,receiver3)
		for index in 1...3 {
			print("\(index) times 5 is \(index * 5)")
			let details:PayPalReceiverPaymentDetails = PayPalReceiverPaymentDetails()
			if index == 2 {
			details.description = "Paid for song"
			}
			details.recipient = "amitmer\(index)"
			details.merchantName = array?.objectAtIndex(index) as! String
			let order:Int = index * 100
			let tax:Int = index * 7
			let shippping:Int = index*14
			details.subTotal = NSDecimalNumber(mantissa: UInt64(order), exponent: -2, isNegative: false)
			details.invoiceData = PayPalInvoiceData()
			details.invoiceData.totalShipping = NSDecimalNumber(mantissa: UInt64(shippping), exponent: -2, isNegative: false)
			details.invoiceData.totalTax = NSDecimalNumber(mantissa: UInt64(tax), exponent: -2, isNegative: false)
			details.invoiceData.invoiceItems = NSMutableArray()
			let item:PayPalInvoiceItem = PayPalInvoiceItem()
			item.totalPrice = details.subTotal
			item.name = "Song"
			details.invoiceData.invoiceItems.addObject(item)
			payment.receiverPaymentDetails.addObject(details)
		}
		PayPal.getPayPalInst().advancedCheckoutWithPayment(payment)
	}
	
	// # MARK: paypalDelgate methods
	
//	- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus;
//	- (void)paymentFailedWithCorrelationID:(NSString *)correlationID;
//	- (void)paymentCanceled;
//	- (void)paymentLibraryExit;

	func retryInitialization() {
		PayPal.initializeWithAppID("APP-80W284485P519543T", forEnvironment: ENV_SANDBOX)
	}
	func paymentSuccessWithKey(paykey:NSString,paymentStatus:PayPalPaymentStatus) {
		//status = PAy
		status = PaymentStatuses.PAYMENTSTATUS_SUCCESS
	}
	func paymentFailedWithCorrelationID(correlationID:NSString){
		status = PaymentStatuses.PAYMENTSTATUS_FAILED
	}
	func paymentLibraryExit(){
		//let alert:UIAlertController = UIAlertController()
		switch status {
		case PaymentStatuses.PAYMENTSTATUS_SUCCESS:
			break
		case PaymentStatuses.PAYMENTSTATUS_FAILED:
			break
		case PaymentStatuses.PAYMENTSTATUS_CANCELED:
			break
		}
		
	}
	func paymentCanceled() {
	status = PaymentStatuses.PAYMENTSTATUS_CANCELED;
	}
	func adjustAmountsForAddress(inAddress:PayPalAddress,inCurrency:NSString,inAmount:NSDecimalNumber,inTax:NSDecimalNumber,inShipping:NSDecimalNumber,outErrorCode:PayPalAmountErrorCode)->PayPalAmounts {
		let newAmounts:PayPalAmounts = PayPalAmounts()
		newAmounts.currency = "USD"
		newAmounts.payment_amount = inAmount
		if inAddress.state == "CA" {
			newAmounts.tax = NSDecimalNumber( float: inAmount .floatValue * 0.1)
		} else {
			newAmounts.tax = NSDecimalNumber( float: inAmount .floatValue * 0.08)
		}
		newAmounts.shipping = inShipping
		return newAmounts
	}
	
//		if ([inAddress.state isEqualToString:@"CA"]) {
//	newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .1]];
//	} else {
//	newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .08]];
//	}
	func adjustAmountsAdvancedForAddress(inAddress:PayPalAddress,inCurrency:NSString,receiverAmounts:NSMutableArray,outErrorCode:PayPalAmountErrorCode)->NSMutableArray {
		let returnArray = NSMutableArray(capacity: receiverAmounts.count)
		for amount in receiverAmounts   {
			let amounts:PayPalReceiverAmounts = amount as! PayPalReceiverAmounts
			if inAddress.state == "CA" {
				amounts.amounts.tax = NSDecimalNumber( float: amounts.amounts.payment_amount .floatValue * 0.1)
			} else {
				amounts.amounts.tax = NSDecimalNumber( float: amounts.amounts.payment_amount  .floatValue * 0.08)
			}
			returnArray.addObject(amounts)
		}
		return returnArray
	}
	
//	if ([inAddress.state isEqualToString:@"CA"]) {
//	amounts.amounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[amounts.amounts.payment_amount floatValue] * .1]];
//	} else {
//	amounts.amounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[amounts.amounts.payment_amount floatValue] * .08]];
//	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

