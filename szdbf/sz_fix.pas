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
  MsgType,BodyLength:UInt32; //BodyLength=���ݼ�ȥУ��λ��У��λ�����ͣ�4λ
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
                  ����ʱ���
          YYYYMMDDHHMMSSsss�����룩��
          YYYY = 0000-9999, MM = 01-12,
          DD = 01-31, HH = 00-23, MM =
          00-59, SS = 00-60 (��)��sss=000-999(����)��}
  ChannelNo:UInt16; // Ƶ������
  MDStreamID:array[0..2] of ansichar;// �������
  SecurityID:array[0..7] of ansichar;//  ֤ȯ����
  SecurityIDSource:array[0..3] of ansichar; {֤ȯ����Դ
                        102=����֤ȯ������
                        103=��۽�����}
  TradingPhaseCode:array[0..7] of ansichar;{��Ʒ�����Ľ��׽׶δ���
                                           �� 0 λ��
                                           S=����������ǰ��
                                           O=���̼��Ͼ���
                                           T=��������
                       B=����
                       C=���̼��Ͼ���
                       E=�ѱ���
                       H=��ʱͣ��
                       A=�̺���
                       V=�������ж�
                       �� 1 λ��
                       0=����״̬
                       1=ȫ��ͣ��}
  PrevClosePx:uint64;  //���ռ� 13(4)
  NumTrades:UInt64;  //�ɽ�����
  TotalVolumeTrade:UInt64;  //�ɽ�����15(2)
  TotalValueTrade:UInt64;  //�ɽ��ܽ��18(4)
  NoMDEntries:uint32; //  ������Ŀ����orͳ����ָ����������
 end;

 MDEntry=packed record
  MDEntryType:array[0..1] of ansichar;{
                                       ������Ŀ���
                     0=����
                     1=����
                     2=�����
                     4=���̼�
                     7=��߼�
                     8=��ͼ�
                     x1=����һ
                     x2=������
                     x3=������ܣ���������Ȩƽ���ۣ�
                     x4=�������ܣ���������Ȩƽ���ۣ�
                     x5=��Ʊ��ӯ��һ
                     x6=��Ʊ��ӯ�ʶ�
                     x7=���� T-1 �վ�ֵ
                     x8=����ʵʱ�ο���ֵ������ ETF�� IOPV��
                     x9=Ȩ֤�����
                     xe=��ͣ��
                     xf=��ͣ��
                     xg=��Լ�ֲ���}
  MDEntryPx:UInt64;  //  �۸�18(6)
  MDEntrySize:UInt64;//   ����
  MDPriceLevel:UInt16;//  �����̵�λ
  NumberOfOrders:UInt64;{
                        ��λ��ί�б���
              Ϊ 0 ��ʾ����ʾ}
  NoOrders:integer;  //��λ��ʾί�б���  Ϊ 0 ��ʾ����ʾ
 end;
 wt_l2=packed record
   ChannelNo:uint16;//  Ƶ������
   ApplSeqNum:UInt64;//��Ϣ��¼�� �� 1 ��ʼ����
   MDStreamID:array[0..2] of AnsiChar;//  �������
   SecurityID:array[0..7] of AnsiChar;//  ֤ȯ����
   SecurityIDSource:array[0..3] of AnsiChar;//  ֤ȯ����Դ
   Price:uint64;  //ί�м۸�18(6);
   OrderQty:UInt64;//  ί������
   Side:AnsiChar;  //�������� 1=��,2=��,G=����,F=����
   TransactTime:UInt64;//  ί��ʱ��
   OrdType:AnsiChar;//������� 1=�м�,2=�޼�,U=��������
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
