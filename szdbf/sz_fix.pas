unit sz_fix;

interface
type
 head=record
  MsgType,BodyLength:UInt32; //BodyLength=���ݼ�ȥУ��λ��У��λ�����ͣ�4λ
 end;

 login=record
  case integer of
  0:(SenderCompID:array[0..19] of ansichar;
    TargetCompID:array[0..19] of ansichar;
    HeartBtInt:UInt32;
    Password:array[0..15] of ansichar;
    DefaultApplVerID:array[0..31] of ansichar);
  1:(by:array [0..91] of byte);
  end;

 Channel_Heartbeat=record
  ChannelNo:UInt16;
  ApplLastSeqNum:UInt64;
  EndOfChannel:boolean;
 end;

 stock_data=record
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

 MDEntry=record
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

// cks += (uint32)buf[ idx++ ],return chs%256;

  //Heartbeat=head+Checksum

implementation


end.
