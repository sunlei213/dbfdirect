unit sz_fix;

interface
type
 uin16=packed record
   case Integer of
   0:(i16:UInt16);
   1:(by16:array [0..1] of Byte);
 end;
 uin32=packed record
   case Integer of
   0:(i32:UInt32);
   1:(by32:array [0..3] of Byte);
 end;
 uin64=packed record
   case Integer of
   0:(i64:UInt64);
   1:(by64:array [0..7] of Byte);
 end;
 head=packed record
  MsgType,BodyLength:UInt32; //BodyLength=内容减去校验位，校验位是整型，4位
 end;
 login_body=packed record
    SenderCompID:array[0..19] of ansichar;
    TargetCompID:array[0..19] of ansichar;
    HeartBtInt:UInt32;
    Password:array[0..15] of ansichar;
    DefaultApplVerID:array[0..31] of ansichar;
 end;
 login= packed record
//  case integer of
//  0:
    l_head:head;
    SenderCompID:array[0..19] of ansichar;
    TargetCompID:array[0..19] of ansichar;
    HeartBtInt:UInt32;
    Password:array[0..15] of ansichar;
    DefaultApplVerID:array[0..31] of ansichar;
//  1:(by:array [0..91] of byte);
  end;

 Channel_Heartbeat=packed record
  ChannelNo:UInt16;
  ApplLastSeqNum:UInt64;
  EndOfChannel:boolean;
 end;
 Tlogin=packed record
//  case Integer of
  TL_body:login;TL_Check:UInt32;
//  1:(By:array[0..103] of Byte);
 end;
 stock_data=packed record
  OrigTime:uint64;{
                  本地时间戳
          YYYYMMDDHHMMSSsss（毫秒），
          YYYY = 0000-9999, MM = 01-12,
          DD = 01-31, HH = 00-23, MM =
          00-59, SS = 00-60 (秒)，sss=000-999(毫秒)。}
  ChannelNo:UInt16; // 频道代码
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
  PrevClosePx:uint64;  //昨收价 13(4)
  NumTrades:UInt64;  //成交笔数
  TotalVolumeTrade:UInt64;  //成交总量15(2)
  TotalValueTrade:UInt64;  //成交总金额18(4)
  NoMDEntries:uint32; //  行情条目个数or统计量指标样本个数
 end;

 MDEntry=packed record
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
  MDEntryPx:UInt64;  //  价格18(6)
  MDEntrySize:UInt64;//   数量
  MDPriceLevel:UInt16;//  买卖盘档位
  NumberOfOrders:UInt64;{
                        价位总委托笔数
              为 0 表示不揭示}
  NoOrders:integer;  //价位揭示委托笔数  为 0 表示不揭示
 end;
 wt_l2=packed record
   ChannelNo:uint16;//  频道代码
   ApplSeqNum:UInt64;//消息记录号 从 1 开始计数
   MDStreamID:array[0..2] of AnsiChar;//  行情类别
   SecurityID:array[0..7] of AnsiChar;//  证券代码
   SecurityIDSource:array[0..3] of AnsiChar;//  证券代码源
   Price:uint64;  //委托价格18(6);
   OrderQty:UInt64;//  委托数量
   Side:AnsiChar;  //买卖方向 1=买,2=卖,G=借入,F=出借
   TransactTime:UInt64;//  委托时间
   OrdType:AnsiChar;//订单类别 1=市价,2=限价,U=本方最优
 end;
 function strtospace(sl:string;Leng:Integer;var outchar:array of AnsiChar):Boolean;
 function i16_l2h(v:UInt16):UInt16;
 function i32_l2h(v:Uint32):UInt32;
 function i64_l2h(v:UInt64):UInt64;
 function a16_l2h(v:UInt16):UInt16;
 function a32_l2h(v:Uint32):UInt32;
 function a64_l2h(v:UInt64):UInt64;
// cks += (uint32)buf[ idx++ ],return chs%256;

  //Heartbeat=head+Checksum


implementation
  function strtospace(sl:string;Leng:Integer;var outchar:array of AnsiChar):Boolean;
  var
  I: Integer;
  begin
    try
    FillChar(outchar,leng,32);
    if Length(sl)>0 then
    for I := 0 to Length(sl)-1 do
      begin
        outchar[i]:=AnsiChar(sl[i+1]);
      end;
    Result:=True;
    except
    result:=False;
    end;
  end;
function i16_l2h(v:UInt16):UInt16;
var
i,j:uin16;
begin
  i.i16:=v;
  j.by16[0]:=i.by16[1];
  j.by16[1]:=i.by16[0];
  Result:=j.i16;
end;
function i32_l2h(v:Uint32):UInt32;
var
i,j:uin32;
k:Integer;
begin
  i.i32:=v;
  for k := 0 to 3 do
    j.by32[k]:=i.by32[3-k];
  Result:=j.i32;
end;

function i64_l2h(v:UInt64):UInt64;
var
i,j:uin64;
k:Integer;
begin
  i.i64:=v;
  for k := 0 to 7 do
    j.by64[k]:=i.by64[7-k];
  Result:=j.i64;
end;

function a16_l2h(v:UInt16):UInt16;
begin
   asm
     xchg ah,al
     mov result,ax
   end;
end;


function a32_l2h(v:Uint32):UInt32;
begin
   asm
     bswap eax
     mov result,eax
   end;
end;

function a64_l2h(v:UInt64):UInt64;
begin
{$IF Defined(CPUX86)}
asm
 MOV     EDX,[DWORD PTR EBP + 12]
 MOV     EAX,[DWORD PTR EBP + 8]
 BSWAP   EAX
 XCHG    EAX,EDX
 BSWAP   EAX
 mov     [DWORD PTR EBP - 8],eax
 mov     [DWORD PTR EBP - 4],edx
end;
{$ELSEIF Defined(CPUX64)}
asm
  MOV    RAX,RCX
  BSWAP  RAX
  mov    result,RAX
end;
{$ELSE}
  {$Message Fatal 'Unsupported architecture'}
{$ENDIF}
end;
end.
