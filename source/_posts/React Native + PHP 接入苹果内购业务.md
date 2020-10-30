---
title: React Native + PHP 接入苹果内购业务
date: 2020-10-30 22:06:26
categories: 苹果内购
top_img: https://cos-study.jinlinle.com/nova/ishot2020-10-30-222317-1604067818dGGUk.png
cover: https://cos-study.jinlinle.com/nova/ishot2020-10-30-222317-1604067818dGGUk.png
tags:
  - React Native
  - PHP
  - 苹果内购
---

## 环境准备

- 首先需要与苹果签订付费 App 协议，https://appstoreconnect.apple.com/agreements/#/

![image-20201030143215117](https://cos-study.jinlinle.com/nova/ishot2020-10-30-152702-1604042844o9rzF.png)

在这里显示“有效”后即可。

- 创建 App，点击 App 内购买项目中的管理

- 根据需求创建商品，注意商品 ID 不能带“.”

## 客户端唤起购买程序

- 使用@刘智鹏写好的包: “react-native-apple-iap”，http://code.haxibiao.cn/packages/react-native-apple-iap
- 仔细阅读完其中的 README.md，字不多，都是白话文的干货
- 使用 yarn 引入到项目中

### coding

- 在`App.tsx`中监听 Apple 内购程序

```tsx
...
		/**
    *  处理Apple内购监听
    */
    useEffect(() => {
        if (Platform.OS == 'ios') {
            ApplePurchase.startObserving();
            return () => {
                ApplePurchase.stopObserving();
            }
        }
    }, []);
...
```

- 在充值页面中加入监听代码

```tsx
...
		let subscription = null
		if (!isAndroid) {
			subscription = subscribe((data: any) => {
				if (data.state == "Purchased") {
					//data中还包含 receipt 以及 identifier
					console.log('data.receipt', data.receipt)
					callRechargeVIP({
						variables: {
							receipt: data.receipt,
						}
					}).then((result) => {
						console.log('购买成功结果 -- ', result)
						notifyStore.makeToast("购买成功!");
					})
					ApplePurchase.completePurchasedTransaction(data.identifier, (error, data) => {
						if (data[0] == "true") {
							console.log("Apple IAP 购买成功");
						}
					});
					setPaying(false)
				} else if (data.state == "Purchasing") {
					//正在购买中
					console.log("Apple IAP 购买中")
					setPaying(true)
				} else if (data.state == "Failed") {
					//购买失败
					console.log("Apple IAP 购买失败")
					setPaying(false)
				} else if (data.state == "Deferred") {
					//未知错误
					console.log("Apple IAP 未知错误")
					setPaying(false)
				}
			});
			ApplePurchase.handleUncompletePurchasedTransactions();
		}
		return () => {
			if (!isAndroid && subscription != null) {
				subscription.remove();
			}
		}
	}, []);
...
```

以上是我的业务处理逻辑。

- 触发唤起 ApplePay 程序

```tsx
<Pressable
  onPress={() => {
    ApplePurchase.supportMakePayments().then((support) => {
      console.log("support", support);
      if (support) {
        ApplePurchase.purchaseWithProductID(vipList[chooseItem]?.product_id);
      }
    });
  }}
  style={{
    width: sw * 0.9,
    height: sh * 0.06,
    alignItems: "center",
    justifyContent: "center",
  }}
>
  <Text style={{ color: "black", fontSize: font(17), marginLeft: 5 }}>
    {vipList ? vipList[chooseItem].amount : ""}元 立即开通
  </Text>
</Pressable>
```

其中的 product_id 是在苹果创建的商品 id。

支付完成后，前端需要存储好 `data.identifier`，后端效验支付状态要用。

## 服务端商品列表

```php
public static function rechargeList()
    {
        return [
            [
                'day'        => '7天',
                'amount'     => '1',
                'product_id' => 'vip_1',
            ],
            [
                'day'        => '25天',
                'amount'     => '3',
                'product_id' => 'vip_3',
            ],
            [
                'day'        => '60天',
                'amount'     => '6',
                'product_id' => 'vip_6',
            ],
        ];
    }
```

格式自己定义，格式有规律 && 前端好解析即可

## 服务端效验苹果支付状态

由于在开发状态下，苹果只给你沙箱环境用，所以后端需要自己识别是沙箱环境还是线上正式环境。

苹果提供两个效验地址：

```php
		/**
     * apple pay 正式环境与沙箱环境回执验证地址
     */
    public const APPLE_BUY_URL         = "https://buy.itunes.apple.com/verifyReceipt";
    public const APPLE_BUY_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt";
```

如果后端拿到的凭据，去正式环境上查询状态，那么得到的信息就是 `21007`

所以，后端是可以处理兼容正式环境和沙箱环境的。

```php
public static function rechargeVIP($receipt, $isSandBox = false)
    {
        $user     = \Auth::user();
        $sendData = "{\"receipt-data\":\"$receipt\"}";
        $url      = $isSandBox ? PremiumUser::APPLE_BUY_SANDBOX_URL : PremiumUser::APPLE_BUY_URL;
        try {
            $client = new Client();
            $result = $client->request('post', $url, [
                'body' => $sendData,
            ])->getBody()->getContents();
            $data = json_decode($result, true);
            // 购买成功
            if ($data['status'] == 0) {
               // 做成功的业务
            } else if ($data['status'] == 21007) {
                return self::rechargeVIP($receipt, true);
            } else {
                throw new GQLException('未支付成功,请稍后再试!');
            }
        } catch (GuzzleException $e) {
            $errorMsg = 'Apple 服务端验证支付失败';
            \Log::error($errorMsg, func_get_args());
            throw new GQLException($errorMsg);
        } catch (\Exception $e) {
            $errorMsg = 'apple 支付处理异常';
            info($e->getMessage());
            \Log::error($errorMsg, func_get_args());
            throw new GQLException($errorMsg);
        }
    }
```

到此就结束了.
