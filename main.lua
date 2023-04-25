--[[

  ____    _____    ___    ____    _ 
 / ___|  |_   _|  / _ \  |  _ \  | |
 \___ \    | |   | | | | | |_) | | |
  ___) |   | |   | |_| | |  __/  |_|
 |____/    |_|    \___/  |_|     (_)
                                    

 You have entered a LunarCloak obfuscated script, any sort of tampering will get you blacklisted from all scripts licensed with LunarCloak.

]]---


local StrToNumber=tonumber;local Byte=string.byte;local Char=string.char;local Sub=string.sub;local Subg=string.gsub;local Rep=string.rep;local Concat=table.concat;local Insert=table.insert;local LDExp=math.ldexp;local GetFEnv=getfenv or function()return _ENV;end ;local Setmetatable=setmetatable;local PCall=pcall;local Select=select;local Unpack=unpack or table.unpack ;local ToNumber=tonumber;local function VMCall(ByteString,vmenv,...)local DIP=1;local repeatNext;ByteString=Subg(Sub(ByteString,5),"..",function(byte)if (Byte(byte,2)==79) then repeatNext=StrToNumber(Sub(byte,1,1));return "";else local a=Char(StrToNumber(byte,16));if repeatNext then local b=Rep(a,repeatNext);repeatNext=nil;return b;else return a;end end end);local function gBit(Bit,Start,End)if End then local Res=(Bit/(2^(Start-1)))%(2^(((End-1) -(Start-1)) + 1)) ;return Res-(Res%1) ;else local Plc=2^(Start-1) ;return (((Bit%(Plc + Plc))>=Plc) and 1) or 0 ;end end local function gBits8()local a=Byte(ByteString,DIP,DIP);DIP=DIP + 1 ;return a;end local function gBits16()local a,b=Byte(ByteString,DIP,DIP + 2 );DIP=DIP + 2 ;return (b * 256) + a ;end local function gBits32()local a,b,c,d=Byte(ByteString,DIP,DIP + 3 );DIP=DIP + 4 ;return (d * 16777216) + (c * 65536) + (b * 256) + a ;end local function gFloat()local Left=gBits32();local Right=gBits32();local IsNormal=1;local Mantissa=(gBit(Right,1,20) * (2^32)) + Left ;local Exponent=gBit(Right,21,31);local Sign=((gBit(Right,32)==1) and  -1) or 1 ;if (Exponent==0) then if (Mantissa==0) then return Sign * 0 ;else Exponent=1;IsNormal=0;end elseif (Exponent==2047) then return ((Mantissa==0) and (Sign * (1/0))) or (Sign * NaN) ;end return LDExp(Sign,Exponent-1023 ) * (IsNormal + (Mantissa/(2^52))) ;end local function gString(Len)local Str;if  not Len then Len=gBits32();if (Len==0) then return "";end end Str=Sub(ByteString,DIP,(DIP + Len) -1 );DIP=DIP + Len ;local FStr={};for Idx=1, #Str do FStr[Idx]=Char(Byte(Sub(Str,Idx,Idx)));end return Concat(FStr);end local gInt=gBits32;local function _R(...)return {...},Select("#",...);end local function Deserialize()local Instrs={};local Functions={};local Lines={};local Chunk={Instrs,Functions,nil,Lines};local ConstCount=gBits32();local Consts={};for Idx=1,ConstCount do local Type=gBits8();local Cons;if (Type==1) then Cons=gBits8()~=0 ;elseif (Type==2) then Cons=gFloat();elseif (Type==3) then Cons=gString();end Consts[Idx]=Cons;end Chunk[3]=gBits8();for Idx=1,gBits32() do local Descriptor=gBits8();if (gBit(Descriptor,1,1)==0) then local Type=gBit(Descriptor,2,3);local Mask=gBit(Descriptor,4,6);local Inst={gBits16(),gBits16(),nil,nil};if (Type==0) then Inst[3]=gBits16();Inst[4]=gBits16();elseif (Type==1) then Inst[3]=gBits32();elseif (Type==2) then Inst[3]=gBits32() -(2^16) ;elseif (Type==3) then Inst[3]=gBits32() -(2^16) ;Inst[4]=gBits16();end if (gBit(Mask,1,1)==1) then Inst[2]=Consts[Inst[2]];end if (gBit(Mask,2,2)==1) then Inst[3]=Consts[Inst[3]];end if (gBit(Mask,3,3)==1) then Inst[4]=Consts[Inst[4]];end Instrs[Idx]=Inst;end end for Idx=1,gBits32() do Functions[Idx-1 ]=Deserialize();end for Idx=1,gBits32() do Lines[Idx]=gBits32();end return Chunk;end local function Wrap(Chunk,Upvalues,Env)local Instr=Chunk[1];local Proto=Chunk[2];local Params=Chunk[3];return function(...)local VIP=1;local Top= -1;local Args={...};local PCount=Select("#",...) -1 ;local function Loop()local Instr=Instr;local Proto=Proto;local Params=Params;local _R=_R;local Vararg={};local Lupvals={};local Stk={};for Idx=0,PCount do if (Idx>=Params) then Vararg[Idx-Params ]=Args[Idx + 1 ];else Stk[Idx]=Args[Idx + 1 ];end end local Varargsz=(PCount-Params) + 1 ;local Inst;local Enum;while true do Inst=Instr[VIP];Enum=Inst[1];if (Enum<=10) then if (Enum<=4) then if (Enum<=1) then if (Enum==0) then Stk[Inst[2]]=Inst[3];else Stk[Inst[2]]=Upvalues[Inst[3]];end elseif (Enum<=2) then Stk[Inst[2]]={};elseif (Enum>3) then do return;end else Stk[Inst[2]]=Stk[Inst[3]];end elseif (Enum<=7) then if (Enum<=5) then Upvalues[Inst[3]]=Stk[Inst[2]];elseif (Enum==6) then local A=Inst[2];Stk[A]=Stk[A]();else Stk[Inst[2]]=Stk[Inst[3]] + Stk[Inst[4]] ;end elseif (Enum<=8) then local NewProto=Proto[Inst[3]];local NewUvals;local Indexes={};NewUvals=Setmetatable({},{__index=function(_,Key)local Val=Indexes[Key];return Val[1][Val[2]];end,__newindex=function(_,Key,Value)local Val=Indexes[Key];Val[1][Val[2]]=Value;end});for Idx=1,Inst[4] do VIP=VIP + 1 ;local Mvm=Instr[VIP];if (Mvm[1]==3) then Indexes[Idx-1 ]={Stk,Mvm[3]};else Indexes[Idx-1 ]={Upvalues,Mvm[3]};end Lupvals[ #Lupvals + 1 ]=Indexes;end Stk[Inst[2]]=Wrap(NewProto,NewUvals,Env);elseif (Enum==9) then Stk[Inst[2]]=Env[Inst[3]];else Stk[Inst[2]][Inst[3]]=Inst[4];end elseif (Enum<=16) then if (Enum<=13) then if (Enum<=11) then Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];elseif (Enum==12) then local A=Inst[2];local B=Stk[Inst[3]];Stk[A + 1 ]=B;Stk[A]=B[Inst[4]];else Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];end elseif (Enum<=14) then for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end elseif (Enum>15) then Stk[Inst[2]]=Stk[Inst[3]] + Inst[4] ;else local A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));end elseif (Enum<=19) then if (Enum<=17) then Stk[Inst[2]]=Stk[Inst[3]] -Inst[4] ;elseif (Enum>18) then local A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Top));else Stk[Inst[2]]=Stk[Inst[3]] -Stk[Inst[4]] ;end elseif (Enum<=20) then local A=Inst[2];local Results,Limit=_R(Stk[A](Unpack(Stk,A + 1 ,Inst[3])));Top=(Limit + A) -1 ;local Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end elseif (Enum>21) then Stk[Inst[2]]=Wrap(Proto[Inst[3]],nil,Env);else Stk[Inst[2]]=Inst[3]~=0 ;end VIP=VIP + 1 ;end end A,B=_R(PCall(Loop));if  not A[1] then local line=Chunk[4][VIP] or "?" ;error("Script error at ["   .. line   .. "]:"   .. A[2] );else return Unpack(A,2,B);end end;end return Wrap(Deserialize(),{},vmenv)(...);end VMCall("LOL!533O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F55492D496E746572666163652F437573746F6D4649656C642F6D61696E2F5261794669656C642E6C7561030C3O0043726561746557696E646F7703043O004E616D6503213O00436F2O6E65637458207C2054686520466C6173683A204561727468205072696D65030C3O004C6F6164696E675469746C6503083O00436F2O6E65637458030F3O004C6F6164696E675375627469746C65030F3O004C6F6164696E672067616D653O2E03133O00436F6E66696775726174696F6E536176696E6703073O00456E61626C65640100030A3O00466F6C6465724E616D650003083O0046696C654E616D6503073O004269672048756203073O00446973636F726403063O00496E76697465034O00030D3O0052656D656D6265724A6F696E7303093O004B657953797374656D030B3O004B657953652O74696E677303053O005469746C6503083O005375627469746C65030A3O004B65792053797374656D03043O004E6F746503093O005369726975734B657903073O00536176654B65792O01030F3O00477261624B657946726F6D536974652O033O004B657903053O0048652O6C6F03093O0043726561746554616203043O00486F6D65028O00030D3O0043726561746553656374696F6E03073O0057656C636F6D65030B3O004372656174654C6162656C031F3O00546865206F6E6C7920646576656C6F7065722069732047616D657346616D6503203O00446973636F72643A20646973636F72642E696F2F6368692O6C73706F74726278032F3O00466F72207468697320746F20776F726B20796F75206E2O656420616E79207370656369616C20636861726163746572033A3O006F74686572776973652C2075736520636F646520434F4D49435320696E2074686520636F646573207468656E207573652074686520736B696E2E03163O0054686520466C6173683A204561727468205072696D65030B3O0053702O656420412O646572030C3O0043726561746542752O746F6E03093O002B31302073702O656403043O00496E666F030E3O00412O64732031302073702O65642E03083O00496E7465726163742O033O00412O6403083O0043612O6C6261636B03093O002B35302073702O6564030E3O00412O64732035302073702O65642E030A3O002B312O302073702O6564030F3O00412O647320312O302073702O65642E030B3O00437265617465496E70757403103O00412O6420637573746F6D2073702O6564031D3O00412O64206120637573746F6D20616D6F756E74206F662073702O65642E030F3O00506C616365686F6C646572546578742O033O00333235030B3O004E756D626572734F6E6C7903073O004F6E456E74657203183O0052656D6F7665546578744166746572466F6375734C6F737403113O00412O6420637573746F6D20616D6F756E74031B3O00412O64732074686520616D6F756E7420796F752077616E7465642E030C3O0053702O65642053652O74657203103O0053657420637573746F6D2073702O6564031E3O0053657473206120637573746F6D20616D6F756E74206F662073702O65642E03113O0053657420637573746F6D20616D6F756E74031B3O00536574732074686520616D6F756E7420796F752077616E7465642E2O033O00536574030D3O0053702O65642072656D6F76657203093O002D31302073702O656403083O00537562747261637403093O002D35302073702O6564030A3O002D312O302073702O656403153O00537562747261637420637573746F6D2073702O656403223O005375627472616374206120637573746F6D20616D6F756E74206F662073702O65642E03163O00537562747261637420637573746F6D20616D6F756E7403203O005375627472616374732074686520616D6F756E7420796F752077616E7465642E03273O0049272O6C20612O64206D6F7265207768656E2072656C656173652064756520746F20627567732E00C03O0012093O00013O001209000100023O00200C00010001000300122O000300044O0014000100034O00135O00022O00063O0001000200200C00013O00052O000200033O000700300A00030006000700300A00030008000900300A0003000A000B2O000200043O000300300A0004000D000E00300A0004000F001000300A00040011001200100B0003000C00042O000200043O000300300A0004000D000E00300A00040014001500300A00040016000E00100B00030013000400300A00030017000E2O000200043O000700300A00040019000900300A0004001A001B00300A0004001C001500300A00040011001D00300A0004001E001F00300A00040020000E00300A00040021002200100B0003001800042O000F00010003000200200C00020001002300122O000400243O00122O000500254O000F00020005000200200C00030002002600122O000500274O001500066O000F00030006000200200C00040002002800122O000600294O0003000700034O000F00040007000200200C00050002002800122O0007002A4O0003000800034O000F00050008000200200C00060002002800122O0008002B4O0003000900034O000F00060009000200200C00070002002800122O0009002C4O0003000A00034O000F0007000A000200200C00080001002300122O000A002D3O00122O000B00254O000F0008000B000200200C00090008002600122O000B002E4O0015000C00014O000F0009000C000200200C000A0008002F2O0002000C3O000400300A000C0006003000300A000C0031003200300A000C00330034000216000D5O00100B000C0035000D2O000F000A000C000200200C000B0008002F2O0002000D3O000400300A000D0006003600300A000D0031003700300A000D00330034000216000E00013O00100B000D0035000E2O000F000B000D000200200C000C0008002F2O0002000E3O000400300A000E0006003800300A000E0031003900300A000E00330034000216000F00023O00100B000E0035000F2O000F000C000E00022O000E000D000D3O00200C000E0008003A2O000200103O000700300A00100006003B00300A00100031003C00300A0010003D003E00300A0010003F001F00300A00100040000E00300A00100041000E00060800110003000100012O00033O000D3O00100B0010003500112O000F000E0010000200200C000F0008002F2O000200113O000400300A00110006004200300A00110031004300300A00110033003400060800120004000100012O00033O000D3O00100B0011003500122O000F000F0011000200200C00100008002600122O001200444O0015001300014O000F0010001300022O000E001100113O00200C00120008003A2O000200143O000700300A00140006004500300A00140031004600300A0014003D003E00300A0014003F001F00300A00140040000E00300A00140041000E00060800150005000100012O00033O00113O00100B0014003500152O000F00120014000200200C00130008002F2O000200153O000400300A00150006004700300A00150031004800300A00150033004900060800160006000100012O00033O00113O00100B0015003500162O000F00130015000200200C00140008002600122O0016004A4O0015001700014O000F00140017000200200C00150008002F2O000200173O000400300A00170006004B00300A00170031003200300A00170033004C000216001800073O00100B0017003500182O000F00150017000200200C00160008002F2O000200183O000400300A00180006004D00300A00180031003700300A00180033004C000216001900083O00100B0018003500192O000F00160018000200200C00170008002F2O000200193O000400300A00190006004E00300A00190031003900300A00190033004C000216001A00093O00100B00190035001A2O000F0017001900022O000E001800183O00200C00190008003A2O0002001B3O000700300A001B0006004F00300A001B0031005000300A001B003D003E00300A001B003F001F00300A001B0040000E00300A001B0041000E000608001C000A000100012O00033O00183O00100B001B0035001C2O000F0019001B000200200C001A0008002F2O0002001C3O000400300A001C0006005100300A001C0031005200300A001C0033004C000608001D000B000100012O00033O00183O00100B001C0035001D2O000F001A001C000200200C001B0008002800122O001D00534O0003001E00144O000F001B001E00022O00043O00013O000C3O00093O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C7565026O00244000143O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D00010001000800201000010001000900100B3O000800012O00043O00017O00143O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000C3O000D3O00093O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C7565026O00494000143O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D00010001000800201000010001000900100B3O000800012O00043O00017O00143O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O000F3O00103O00093O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C7565026O00594000143O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D00010001000800201000010001000900100B3O000800012O00043O00017O00143O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00123O00137O0001024O00058O00043O00017O00023O00163O00173O00083O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C756500153O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D0001000100082O000100026O000700010001000200100B3O000800012O00043O00017O00153O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O00193O001A7O0001024O00058O00043O00017O00023O001E3O001F3O00083O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C7565000B3O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O00072O000100015O00100B3O000800012O00043O00017O000B3O00213O00213O00213O00213O00213O00213O00213O00213O00213O00213O00223O00093O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C7565026O00244000143O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D00010001000800201100010001000900100B3O000800012O00043O00017O00143O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00253O00263O00093O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C7565026O00494000143O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D00010001000800201100010001000900100B3O000800012O00043O00017O00143O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00283O00293O00093O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C7565026O00594000143O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D00010001000800201100010001000900100B3O000800012O00043O00017O00143O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002B3O002C7O0001024O00058O00043O00017O00023O002F3O00303O00083O0003093O00776F726B7370616365030E3O0046696E6446697273744368696C6403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503083O004D617853702O656403053O0056616C756500153O0012093O00013O00200C5O0002001209000200033O00200D00020002000400200D00020002000500200D0002000200062O000F3O0002000200200D5O0007001209000100013O00200C000100010002001209000300033O00200D00030003000400200D00030003000500200D0003000300062O000F00010003000200200D00010001000700200D0001000100082O000100026O001200010001000200100B3O000800012O00043O00017O00153O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00323O00333O00C03O00013O00013O00013O00013O00013O00013O00013O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00023O00033O00033O00033O00033O00043O00043O00043O00043O00053O00053O00053O00053O00063O00063O00063O00063O00073O00073O00073O00073O00083O00083O00083O00083O00093O00093O00093O00093O000A3O000A3O000A3O000A3O000B3O000B3O000B3O000B3O000B3O000D3O000D3O000B3O000E3O000E3O000E3O000E3O000E3O00103O00103O000E3O00113O00113O00113O00113O00113O00133O00133O00113O00143O00153O00153O00153O00153O00153O00153O00153O00153O00173O00173O00173O00153O00183O00183O00183O00183O00183O001A3O001A3O001A3O00183O001B3O001B3O001B3O001B3O001C3O001D3O001D3O001D3O001D3O001D3O001D3O001D3O001D3O001F3O001F3O001F3O001D3O00203O00203O00203O00203O00203O00223O00223O00223O00203O00233O00233O00233O00233O00243O00243O00243O00243O00243O00263O00263O00243O00273O00273O00273O00273O00273O00293O00293O00273O002A3O002A3O002A3O002A3O002A3O002C3O002C3O002A3O002D3O002E3O002E3O002E3O002E3O002E3O002E3O002E3O002E3O00303O00303O00303O002E3O00313O00313O00313O00313O00313O00333O00333O00333O00313O00343O00343O00343O00343O00343O00",GetFEnv(),...);