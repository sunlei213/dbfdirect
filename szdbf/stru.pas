head=record
 MsgType,BodyLength:integer; //BodyLength=内容减去校验位，校验位是整型，4位
end;

login=record
Header:head;
SenderCompID:array[0..19] of ansichar;
TargetCompID:array[0..19] of ansichar;
HeartBtInt:integer;
Password:array[0..15] of ansichar;
DefaultApplVerID:array[0..31] of ansichar;
end;

Checksum:integer;// cks += (uint32)buf[ idx++ ],return chs%256;

Heartbeat= //head+Checksum

Channel_Heartbeat=record
Header:head;
ChannelNo:short;
ApplLastSeqNum:int64;
EndOfChannel:boolean;
end;

stock_data=record
Header:head;
OrigTime:int64;{
                本地时间戳
				YYYYMMDDHHMMSSsss（毫秒），
				YYYY = 0000-9999, MM = 01-12,
				DD = 01-31, HH = 00-23, MM =
				00-59, SS = 00-60 (秒)，sss=000-999(毫秒)。}
ChannelNo:short;  频道代码
MDStreamID:array[0..2] of ansichar;// 行情类别
SecurityID:array[0..7] of ansichar;//  证券代码
SecurityIDSource:array[0..3] of ansichar; {证券代码源
										  102=深圳证券交易所
										  103=香港交易所}
TradingPhaseCode:array[0..7] of ansichar;{产品所处的交易阶段代码
                                         第 0 位：
                                         S=启动（开市前）
                                         O=开盘集合竞价
                                         T=连续竞价
										 B=休市
										 C=收盘集合竞价
										 E=已闭市
										 H=临时停牌
										 A=盘后交易
										 V=波动性中断
										 第 1 位：
										 0=正常状态
										 1=全天停牌}
PrevClosePx:int64;  //昨收价 13(4)
NumTrades:int64;  //成交笔数
TotalVolumeTrade:int64;  //成交总量15(2)
TotalValueTrade:int64;  //成交总金额18(4)
NoMDEntries:uint32; //  行情条目个数or统计量指标样本个数
end;

MDEntry=record
MDEntryType:array[0..1] of ansichar;{
                                     行情条目类别
									 0=买入
									 1=卖出
									 2=最近价
									 4=开盘价
									 7=最高价
									 8=最低价
									 x1=升跌一
									 x2=升跌二
									 x3=买入汇总（总量及加权平均价）
									 x4=卖出汇总（总量及加权平均价）
									 x5=股票市盈率一
									 x6=股票市盈率二
									 x7=基金 T-1 日净值
									 x8=基金实时参考净值（包括 ETF的 IOPV）
									 x9=权证溢价率
									 xe=涨停价
									 xf=跌停价
									 xg=合约持仓量}
MDEntryPx:int64;  //  价格18(6)
MDEntrySize:int64;//   数量
MDPriceLevel:short;//  买卖盘档位
NumberOfOrders:int64;{
                      价位总委托笔数
					  为 0 表示不揭示}
NoOrders:integer;  //价位揭示委托笔数  为 0 表示不揭示
end;
