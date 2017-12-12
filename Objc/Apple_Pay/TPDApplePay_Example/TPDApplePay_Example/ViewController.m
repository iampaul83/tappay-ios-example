//
//  ViewController.m
//  TPDApplePay_Example
//
//  Copyright © 2017年 Cherri Tech Inc. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "ViewController.h"
#import <TPDirect/TPDirect.h>

@interface ViewController () <WKScriptMessageHandler>

@property (nonatomic, strong) TPDMerchant *merchant;
@property (nonatomic, strong) TPDConsumer *consumer;
@property (nonatomic, strong) TPDCart *cart;
@property (nonatomic, strong) TPDApplePay *applePay;

@property (strong, nonatomic) WKWebView *webView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self merchantSetting];
    [self consumerSetting];
    [self cartSetting];
    [self paymentButtonSetting];
    [self setupWKWebView];
}

- (void)startApplePay {
    self.applePay = [TPDApplePay setupWthMerchant:self.merchant
                                     withConsumer:self.consumer
                                         withCart:self.cart
                                     withDelegate:self];
    [self.applePay startPayment];
}

- (void)setupApplePay {
    [TPDApplePay showSetupView];
}

- (void)paymentButtonSetting {
    // Check Consumer / Application Can Use Apple Pay.
    if (![TPDApplePay canMakePaymentsUsingNetworks:self.merchant.supportedNetworks]) {
        // @TODO: show set up apple pay button
        // see: https://developer.apple.com/documentation/applepayjs/displaying_apple_pay_buttons

        return;
    }
    
    // Check Device Support Apple Pay
    if ([TPDApplePay canMakePayments]) {
        // @TODO: show apple pay button
        // see: https://developer.apple.com/documentation/applepayjs/displaying_apple_pay_buttons
        
    }
    
}

- (void)merchantSetting {
    
    self.merchant = [TPDMerchant new];
    self.merchant.merchantName               = @"TapPay!";
    self.merchant.merchantCapability         = PKMerchantCapability3DS;
    // Your Apple Pay Merchant ID (register at https://developer.apple.com/account/ios/identifier/merchant)
    self.merchant.applePayMerchantIdentifier = @"merchant.tech.cherri.global.test";
    self.merchant.countryCode                = @"TW";
    self.merchant.currencyCode               = @"TWD";
    self.merchant.supportedNetworks          = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    
    
    // Set Shipping Method.
    PKShippingMethod *shipping1 = [PKShippingMethod new];
    shipping1.identifier = @"TapPayExpressShippint024";
    shipping1.detail     = @"Ships in 24 hours";
    shipping1.amount     = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    shipping1.label      = @"Shipping 24";
    
    PKShippingMethod *shipping2 = [PKShippingMethod new];
    shipping2.identifier = @"TapPayExpressShippint006";
    shipping2.detail     = @"Ships in 6 hours";
    shipping2.amount     = [NSDecimalNumber decimalNumberWithString:@"50.0"];
    shipping2.label      = @"Shipping 6";
    
    self.merchant.shippingMethods = @[shipping1, shipping2];
    
    
}

- (void)consumerSetting {
    // Set Consumer Contact.
    PKContact *contact  = [PKContact new];
    NSPersonNameComponents *name = [NSPersonNameComponents new];
    name.familyName = @"Cherri";
    name.givenName  = @"TapPay";
    contact.name    = name;
    
    self.consumer = [TPDConsumer new];
    self.consumer.billingContact    = contact;
    self.consumer.shippingContact   = contact;
    self.consumer.requiredShippingAddressFields  = PKAddressFieldEmail | PKAddressFieldName | PKAddressFieldPhone;
    self.consumer.requiredBillingAddressFields   = PKAddressFieldEmail | PKAddressFieldName | PKAddressFieldPhone;
    
}

- (void)cartSetting {
    
    self.cart = [TPDCart new];
    
    TPDPaymentItem *book = [TPDPaymentItem paymentItemWithItemName:@"Book"
                                                        withAmount:[NSDecimalNumber decimalNumberWithString:@"100.00"]];
    [self.cart addPaymentItem:book];
    
    TPDPaymentItem *discount  = [TPDPaymentItem paymentItemWithItemName:@"Discount"
                                                             withAmount:[NSDecimalNumber decimalNumberWithString:@"-3.00"]];
    [self.cart addPaymentItem:discount];
    
    TPDPaymentItem *tax  = [TPDPaymentItem paymentItemWithItemName:@"Tax"
                                                        withAmount:[NSDecimalNumber decimalNumberWithString:@"6.00"]];
    [self.cart addPaymentItem:tax];
    
    self.cart.shippingType   = PKShippingTypeShipping;
    
}

- (void)setupWKWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    
    // register message handler, so we can use `webkit.messageHandlers.appHandler.postMessage` in JavaScript
    [controller addScriptMessageHandler:self name:@"appHandler"];
    configuration.userContentController = controller;
    
    NSURL *url = [NSURL URLWithString:@"https://tappay-ios-sdk-with-wkwebview.netlify.com"];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:configuration];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_webView];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - WKScriptMessageHandler
// handle message from WKWebView
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.body isEqualToString:@"applePay"]) {
        [self startApplePay];
    }
}

#pragma mark - TPDApplePayDelegate
- (void)tpdApplePayDidStartPayment:(TPDApplePay *)applePay {
    
    NSLog(@"=====================================================");
    NSLog(@"Apple Pay On Start");
    NSLog(@"===================================================== \n\n");
}

- (void)tpdApplePay:(TPDApplePay *)applePay didSuccessPayment:(TPDTransactionResult *)result {
    
    NSLog(@"=====================================================");
    NSLog(@"Apple Pay Did Success ==> Amount : %@", [result.amount stringValue]);
    
    NSLog(@"shippingContact.name : %@ %@", applePay.consumer.shippingContact.name.givenName, applePay.consumer.shippingContact.name.familyName);
    NSLog(@"shippingContact.emailAddress : %@", applePay.consumer.shippingContact.emailAddress);
    NSLog(@"shippingContact.phoneNumber : %@", applePay.consumer.shippingContact.phoneNumber.stringValue);
    NSLog(@"===================================================== \n\n");
    
}

- (void)tpdApplePay:(TPDApplePay *)applePay didFailurePayment:(TPDTransactionResult *)result {
    
    NSLog(@"=====================================================");
    NSLog(@"Apple Pay Did Failure ==> Message : %@, ErrorCode : %ld", result.message, (long)result.status);
    NSLog(@"===================================================== \n\n");
}

- (void)tpdApplePayDidCancelPayment:(TPDApplePay *)applePay {
    
    NSLog(@"=====================================================");
    NSLog(@"Apple Pay Did Cancel");
    NSLog(@"===================================================== \n\n");
}

- (void)tpdApplePayDidFinishPayment:(TPDApplePay *)applePay {
    
    NSLog(@"=====================================================");
    NSLog(@"Apple Pay Did Finish");
    NSLog(@"===================================================== \n\n");
}

- (void)tpdApplePay:(TPDApplePay *)applePay didSelectShippingMethod:(PKShippingMethod *)shippingMethod {
    
    NSLog(@"=====================================================");
    NSLog(@"======> didSelectShippingMethod: ");
    NSLog(@"Shipping Method.identifier : %@", shippingMethod.identifier);
    NSLog(@"Shipping Method.detail : %@", shippingMethod.detail);
    NSLog(@"===================================================== \n\n");
    
}

- (TPDCart *)tpdApplePay:(TPDApplePay *)applePay didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod cart:(TPDCart *)cart {
    
    NSLog(@"=====================================================");
    NSLog(@"======> didSelectPaymentMethod: ");
    NSLog(@"===================================================== \n\n");
    
    if (paymentMethod.type == PKPaymentMethodTypeDebit) {
        [self.cart addPaymentItem:[TPDPaymentItem paymentItemWithItemName:@"Discount"
                                                               withAmount:[NSDecimalNumber decimalNumberWithString:@"-1.00"]]];
    }
    
    return self.cart;
}


- (BOOL)tpdApplePay:(TPDApplePay *)applePay canAuthorizePaymentWithShippingContact:(PKContact *)shippingContact {
    
    NSLog(@"=====================================================");
    NSLog(@"======> canAuthorizePaymentWithShippingContact ");
    NSLog(@"shippingContact.name : %@ %@", shippingContact.name.givenName, shippingContact.name.familyName);
    NSLog(@"shippingContact.emailAddress : %@", shippingContact.emailAddress);
    NSLog(@"shippingContact.phoneNumber : %@", shippingContact.phoneNumber.stringValue);
    NSLog(@"===================================================== \n\n");
    return YES;
}

// With Payment Handle
- (void)tpdApplePay:(TPDApplePay *)applePay didReceivePrime:(NSString *)prime {
    
    // 1. Send Your 'Prime' To Your Server, And Handle Payment With Result
    // ...
    NSLog(@"=====================================================");
    NSLog(@"======> didReceivePrime ");
    NSLog(@"Prime : %@", prime);
    NSLog(@"totalAmount : %@",applePay.cart.totalAmount);
    NSLog(@"Client  IP : %@",applePay.consumer.clientIP);
    NSLog(@"shippingContact.name : %@ %@", applePay.consumer.shippingContact.name.givenName, applePay.consumer.shippingContact.name.familyName);
    NSLog(@"shippingContact.emailAddress : %@", applePay.consumer.shippingContact.emailAddress);
    NSLog(@"shippingContact.phoneNumber : %@", applePay.consumer.shippingContact.phoneNumber.stringValue);
    NSLog(@"===================================================== \n\n");
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // post result back to WKWebView
        NSString *exec_template = @"applePayCallback('%@', %@);";
        NSString *exec = [NSString stringWithFormat:exec_template, prime, applePay.cart.totalAmount];
        [_webView evaluateJavaScript:exec completionHandler:nil];
    });
    
    
    // 2. If Payment Success, set paymentReault = YES.
    BOOL paymentReault = YES;
    // Dissmiss Apple Pay Payment Sheet
    [applePay showPaymentResult:paymentReault];
    
}



@end
