-----------------------------------------------------------------------------------
--!     @file    reducer.vhd
--!     @brief   REDUCER MODULE :
--!              異なるデータ幅のパスを継ぐためのアダプタ
--!     @version 1.5.8
--!     @date    2015/9/20
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2015 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
-----------------------------------------------------------------------------------
--! @brief   REDUCER :
--!          異なるデータ幅のパスを継ぐためのアダプタ.
--!        * REDUCER とは配管用語で径違い継ぎ手、つまり直径違う配管(パイプ)を接続
--!          するために用いる管継手のことです.
--!        * 論理回路の世界でも、ビット幅の異なるデータパスどうしを継ぐことが多い
--!          のでこのような汎用のアダプタを作って REDUCER という名前をつけました.
--!        * ちょっと汎用的に作りすぎたせいか、多少回路が冗長です.
--!          特にI_WIDTHが大きいとかなり大きな回路になってしまいます.
--!          例えば32bit入力64bit出力の場合、
--!          WORD_BITS=8 、STRB_BITS=1、I_WIDTH=4、O_WIDTH=8 とするよりも、
--!          WORD_BITS=32、STRB_BITS=4、I_WIDTH=1、O_WIDTH=2 としたほうが
--!          回路はコンパクトになります.
--!        * O_WIDTH>I_WIDTHの場合、最初のワードデータを出力する際のオフセットを
--!          設定できます. 詳細はOFFSETの項を参照.
-----------------------------------------------------------------------------------
entity  REDUCER is
    generic (
        WORD_BITS   : --! @brief WORD BITS :
                      --! １ワードのデータのビット数を指定する.
                      integer := 8;
        STRB_BITS   : --! @brief ENABLE BITS :
                      --! ワードデータのうち有効なデータであることを示す信号(STRB)
                      --! のビット数を指定する.
                      integer := 1;
        I_WIDTH     : --! @brief INPUT WORD WIDTH :
                      --! 入力側のデータのワード数を指定する.
                      integer := 1;
        O_WIDTH     : --! @brief OUTPUT WORD WIDTH :
                      --! 出力側のデータのワード数を指定する.
                      integer := 1;
        QUEUE_SIZE  : --! @brief QUEUE SIZE :
                      --! キューの大きさをワード数で指定する.
                      --! * QUEUE_SIZE=0を指定した場合は、キューの深さは自動的に
                      --!   O_WIDTH+I_WIDTH+I_WIDTH-1 に設定される.
                      --! * QUEUE_SIZE<O_WIDTH+I_WIDTH-1の場合は、キューの深さは
                      --!   自動的にO_WIDTH+I_WIDTH-1に設定される.
                      integer := 0;
        VALID_MIN   : --! @brief BUFFER VALID MINIMUM NUMBER :
                      --! VALID信号の配列の最小値を指定する.
                      integer := 0;
        VALID_MAX   : --! @brief BUFFER VALID MAXIMUM NUMBER :
                      --! VALID信号の配列の最大値を指定する.
                      integer := 0;
        O_VAL_SIZE  : --! @brief OUTPUT WORD VALID SIZE :
                      --! O_VAL 信号アサート時のキューに入っているワード数.
                      --! * キューに O_VAL_SIZE 以上のワード数が入っていると O_VAL 
                      --!   信号をアサートする.
                      --! * 互換性維持のため O_VAL_SIZE=0を指定した場合は、キューに
                      --!   O_WIDTH 以上のワード数が入っていると O_VAL 信号をアサー
                      --!   トする.
                      integer := 0;
        O_SHIFT_MIN : --! @brief OUTPUT SHIFT SIZE MINIMUM NUMBER :
                      --! O_SHIFT信号の配列の最小値を指定する.
                      integer := 1;
        O_SHIFT_MAX : --! @brief OUTPUT SHIFT SIZE MINIMUM NUMBER :
                      --! O_SHIFT信号の配列の最大値を指定する.
                      integer := 1;
        I_JUSTIFIED : --! @brief INPUT WORD JUSTIFIED :
                      --! 入力側の有効なデータが常にLOW側に詰められていることを
                      --! 示すフラグ.
                      --! * 常にLOW側に詰められている場合は、シフタが必要なくなる
                      --!   ため回路が簡単になる.
                      integer range 0 to 1 := 0;
        FLUSH_ENABLE: --! @brief FLUSH ENABLE :
                      --! FLUSH/I_FLUSHによるフラッシュ処理を有効にするかどうかを
                      --! 指定する.
                      --! * FLUSHとDONEとの違いは、DONEは最後のデータの出力時に
                      --!   キューの状態をすべてクリアするのに対して、
                      --!   FLUSHは最後のデータの出力時にSTRBだけをクリアしてVALは
                      --!   クリアしない.
                      --!   そのため次の入力データは、最後のデータの次のワード位置
                      --!   から格納される.
                      --! * フラッシュ処理を行わない場合は、0を指定すると回路が若干
                      --!   簡単になる.
                      integer range 0 to 1 := 1
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK         : --! @brief CLOCK :
                      --! クロック信号
                      in  std_logic; 
        RST         : --! @brief ASYNCRONOUSE RESET :
                      --! 非同期リセット信号.アクティブハイ.
                      in  std_logic;
        CLR         : --! @brief SYNCRONOUSE RESET :
                      --! 同期リセット信号.アクティブハイ.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 各種制御信号
    -------------------------------------------------------------------------------
        START       : --! @brief START :
                      --! 開始信号.
                      --! * この信号はOFFSETを内部に設定してキューを初期化する.
                      --! * 最初にデータ入力と同時にアサートしても構わない.
                      in  std_logic := '0';
        OFFSET      : --! @brief OFFSET :
                      --! 最初のワードの出力位置を指定する.
                      --! * START信号がアサートされた時のみ有効.
                      --! * O_WIDTH>I_WIDTHの場合、最初のワードデータを出力する際の
                      --!   オフセットを設定できる.
                      --! * 例えばWORD_BITS=8、I_WIDTH=1(1バイト入力)、O_WIDTH=4(4バイト出力)の場合、
                      --!   OFFSET="0000"に設定すると、最初に入力したバイトデータは
                      --!   1バイト目から出力される.    
                      --!   OFFSET="0001"に設定すると、最初に入力したバイトデータは
                      --!   2バイト目から出力される.    
                      --!   OFFSET="0011"に設定すると、最初に入力したバイトデータは
                      --!   3バイト目から出力される.    
                      --!   OFFSET="0111"に設定すると、最初に入力したバイトデータは
                      --!   4バイト目から出力される.    
                      in  std_logic_vector(O_WIDTH-1 downto 0) := (others => '0');
        DONE        : --! @brief DONE :
                      --! 終了信号.
                      --! * この信号をアサートすることで、キューに残っているデータ
                      --!   を掃き出す.
                      --!   その際、最後のワードと同時にO_DONE信号がアサートされる.
                      --! * FLUSH信号との違いは、FLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        FLUSH       : --! @brief FLUSH :
                      --! フラッシュ信号.
                      --! * この信号をアサートすることで、キューに残っているデータ
                      --!   を掃き出す.
                      --!   その際、最後のワードと同時にO_FLUSH信号がアサートされる.
                      --! * DONE信号との違いは、FLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        BUSY        : --! @brief BUSY :
                      --! ビジー信号.
                      --! * 最初にデータが入力されたときにアサートされる.
                      --! * 最後のデータが出力し終えたらネゲートされる.
                      out std_logic;
        VALID       : --! @brief QUEUE VALID FLAG :
                      --! キュー有効信号.
                      --! * 対応するインデックスのキューに有効なワードが入って
                      --!   いるかどうかを示すフラグ.
                      out std_logic_vector(VALID_MAX downto VALID_MIN);
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_ENABLE    : --! @brief INPUT ENABLE :
                      --! 入力許可信号.
                      --! * この信号がアサートされている場合、キューの入力を許可する.
                      --! * この信号がネゲートされている場合、I_RDY アサートされない.
                      in  std_logic := '1';
        I_DATA      : --! @brief INPUT WORD DATA :
                      --! ワードデータ入力.
                      in  std_logic_vector(I_WIDTH*WORD_BITS-1 downto 0);
        I_STRB      : --! @brief INPUT WORD ENABLE :
                      --! ワードストローブ信号入力.
                      in  std_logic_vector(I_WIDTH*STRB_BITS-1 downto 0);
        I_DONE      : --! @brief INPUT WORD DONE :
                      --! 最終ワード信号入力.
                      --! * 最後の力ワードデータ入であることを示すフラグ.
                      --! * 基本的にはDONE信号と同じ働きをするが、I_DONE信号は
                      --!   最後のワードデータを入力する際に同時にアサートする.
                      --! * I_FLUSH信号との違いはFLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        I_FLUSH     : --! @brief INPUT WORD FLUSH :
                      --! 最終ワード信号入力.
                      --! * 最後のワードデータ入力であることを示すフラグ.
                      --! * 基本的にはFLUSH信号と同じ働きをするが、I_FLUSH信号は
                      --!   最後のワードデータを入力する際に同時にアサートする.
                      --! * I_DONE信号との違いはFLUSH_ENABLEの項を参照.
                      in  std_logic := '0';
        I_VAL       : --! @brief INPUT WORD VALID :
                      --! 入力ワード有効信号.
                      --! * I_DATA/I_STRB/I_DONE/I_FLUSHが有効であることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがキューに取り込まれる.
                      in  std_logic;
        I_RDY       : --! @brief INPUT WORD READY :
                      --! 入力レディ信号.
                      --! * キューが次のワードデータを入力出来ることを示す.
                      --! * I_VAL='1'and I_RDY='1'でワードデータがキューに取り込まれる.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_ENABLE    : --! @brief OUTPUT ENABLE :
                      --! 出力許可信号.
                      --! * この信号がアサートされている場合、キューの出力を許可する.
                      --! * この信号がネゲートされている場合、O_VAL アサートされない.
                      in  std_logic := '1';
        O_DATA      : --! @brief OUTPUT WORD DATA :
                      --! ワードデータ出力.
                      out std_logic_vector(O_WIDTH*WORD_BITS-1 downto 0);
        O_STRB      : --! @brief OUTPUT WORD ENABLE :
                      --! ワードストローブ信号出力.
                      out std_logic_vector(O_WIDTH*STRB_BITS-1 downto 0);
        O_DONE      : --! @brief OUTPUT WORD DONE :
                      --! 最終ワード信号出力.
                      --! * 最後のワードデータ出力であることを示すフラグ.
                      --! * O_FLUSH信号との違いはFLUSH_ENABLEの項を参照.
                      out std_logic;
        O_FLUSH     : --! @brief OUTPUT WORD FLUSH :
                      --! 最終ワード信号出力.
                      --! * 最後のワードデータ出力であることを示すフラグ.
                      --! * O_DONE信号との違いはFLUSH_ENABLEの項を参照.
                      out std_logic;
        O_VAL       : --! @brief OUTPUT WORD VALID :
                      --! 出力ワード有効信号.
                      --! * O_DATA/O_STRB/O_DONE/O_FLUSHが有効であることを示す.
                      --! * O_VAL='1'and O_RDY='1'でワードデータがキューから取り除かれる.
                      out std_logic;
        O_RDY       : --! @brief OUTPUT WORD READY :
                      --! 出力レディ信号.
                      --! * キューから次のワードを取り除く準備が出来ていることを示す.
                      --! * O_VAL='1'and O_RDY='1'でワードデータがキューから取り除かれる.
                      in  std_logic;
        O_SHIFT     : --! @brief OUTPUT SHIFT SIZE :
                      --! 出力シフトサイズ信号.
                      --! * キューからワードを出力する際に、何ワード取り除くかを指定する.
                      --! * O_VAL='1' and O_RDY='1'の場合にのみこの信号は有効.
                      --! * 取り除くワードの位置に'1'をセットする.
                      --! * 例) O_SHIFT_MAX=3、O_SHIFT_MIN=0の場合、    
                      --!   O_SHIFT(3 downto 0)="1111" で4ワード取り除く.    
                      --!   O_SHIFT(3 downto 0)="0111" で3ワード取り除く.    
                      --!   O_SHIFT(3 downto 0)="0011" で2ワード取り除く.    
                      --!   O_SHIFT(3 downto 0)="0001" で1ワード取り除く.    
                      --!   O_SHIFT(3 downto 0)="0000" で取り除かない.    
                      --!   上記以外の値を指定した場合は動作を保証しない.
                      --! * 例) O_SHIFT_MAX=3、O_SHIFT_MIN=2の場合、    
                      --!   O_SHIFT(3 downto 2)="11" で4ワード取り除く.    
                      --!   O_SHIFT(3 downto 2)="01" で3ワード取り除く.    
                      --!   O_SHIFT(3 downto 2)="00" で2ワード取り除く.    
                      --!   上記以外の値を指定した場合は動作を保証しない.
                      --! * 例) O_SHIFT_MAX=1、O_SHIFT_MIN=1の場合、    
                      --!   O_SHIFT(1 downto 1)="1" で2ワード取り除く.    
                      --!   O_SHIFT(1 downto 1)="0" で1ワード取り除く.
                      --! * 例) O_SHIFT_MAX=0、O_SHIFT_MIN=0の場合、    
                      --!   O_SHIFT(0 downto 0)="1" で1ワード取り除く.    
                      --!   O_SHIFT(0 downto 0)="0" で取り除かない.
                      --! * 出力ワード数(O_WIDTH)分だけ取り除きたい場合は、
                      --!   O_SHIFT_MAX=O_WIDTH、O_SHIFT_MIN=O_WIDTH、
                      --!   O_SHIFT=(others => '0') としておくと良い.
                      in  std_logic_vector(O_SHIFT_MAX downto O_SHIFT_MIN) := (others => '0')
    );
end REDUCER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of REDUCER is
    -------------------------------------------------------------------------------
    --! @brief ワード単位でデータ/データストローブ信号/ワード有効フラグをまとめておく.
    -------------------------------------------------------------------------------
    type      WORD_TYPE    is record
              DATA          : std_logic_vector(WORD_BITS-1 downto 0);
              STRB          : std_logic_vector(STRB_BITS-1 downto 0);
              VAL           : boolean;
    end record;
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の初期化時の値.
    -------------------------------------------------------------------------------
    constant  WORD_NULL     : WORD_TYPE := (DATA => (others => '0'),
                                            STRB => (others => '0'),
                                            VAL  => FALSE);
    -------------------------------------------------------------------------------
    --! @brief WORD TYPE の配列の定義.
    -------------------------------------------------------------------------------
    type      WORD_VECTOR  is array (INTEGER range <>) of WORD_TYPE;
    -------------------------------------------------------------------------------
    --! @brief 整数の最小値を求める関数.
    -------------------------------------------------------------------------------
    function  minimum(L,R : integer) return integer is
    begin
        if (L < R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 指定されたベクタのリダクション論理和を求める.
    -------------------------------------------------------------------------------
    function  or_reduce(Arg : std_logic_vector) return std_logic is
        variable result : std_logic;
    begin
        result := '0';
        for i in Arg'range loop
            result := result or Arg(i);
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 入力信号のうち最も低い位置の'1'だけを取り出す関数.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- 例) Data(0 to 3) = "1110" => SEL(0 to 3) = "1000"
    --     Data(0 to 3) = "0111" => SEL(0 to 3) = "0100"
    --     Data(0 to 3) = "0011" => SEL(0 to 3) = "0010"
    --     Data(0 to 3) = "0001" => SEL(0 to 3) = "0001"
    --     Data(0 to 3) = "0000" => SEL(0 to 3) = "0000"
    --     Data(0 to 3) = "0101" => SEL(0 to 3) = "0101" <- このような入力は禁止
    -------------------------------------------------------------------------------
    function  priority_selector(
                 Data    : std_logic_vector
    )            return    std_logic_vector
    is
        variable result  : std_logic_vector(Data'range);
    begin
        for i in Data'range loop
            if (i = Data'low) then
                result(i) := Data(i);
            else
                result(i) := Data(i) and (not Data(i-1));
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ワードの配列からSELで指定されたワードを選択する関数.
    -------------------------------------------------------------------------------
    function  select_word(
                 WORDS   :  WORD_VECTOR;
                 SEL     :  std_logic_vector
    )            return     WORD_TYPE
    is
        alias    i_words :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        alias    i_sel   :  std_logic_vector(0 to   SEL'length-1) is SEL;
        variable result  :  WORD_TYPE;
        variable s_vec   :  std_logic_vector(0 to WORDS'length-1);
    begin
        for n in WORD_BITS-1 downto 0 loop
            for i in i_words'range loop
                if (i_sel'low <= i and i <= i_sel'high) then
                    s_vec(i) := i_words(i).DATA(n) and i_sel(i);
                else
                    s_vec(i) := '0';
                end if;
            end loop;
            result.DATA(n) := or_reduce(s_vec);
        end loop;
        for n in STRB_BITS-1 downto 0 loop
            for i in i_words'range loop
                if (i_sel'low <= i and i <= i_sel'high) then
                    s_vec(i) := i_words(i).STRB(n) and i_sel(i);
                else
                    s_vec(i) := '0';
                end if;
            end loop;
            result.STRB(n) := or_reduce(s_vec);
        end loop;
        for i in i_words'range loop
            if (i_sel'low <= i and i <= i_sel'high) then
                if (i_words(i).VAL and i_sel(i) = '1') then
                    s_vec(i) := '1';
                else
                    s_vec(i) := '0';
                end if;
            else
                    s_vec(i) := '0';
            end if;
        end loop;
        result.VAL := (or_reduce(s_vec) = '1');
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューの最後にワードを追加した新しいキューを求める関数.
    -------------------------------------------------------------------------------
    function  append_words(
                 QUEUE   :  WORD_VECTOR;
                 WORDS   :  WORD_VECTOR
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_val   :  std_logic_vector(0 to WORDS'length-1);
        variable i_sel   :  std_logic_vector(0 to WORDS'length-1);
        type     bv      is array (INTEGER range <>) of boolean;
        variable q_val   :  bv(QUEUE'low to QUEUE'high);
        variable result  :  WORD_VECTOR     (QUEUE'range);
    begin
        for q in QUEUE'range loop
            q_val(q) := QUEUE(q).VAL;
        end loop;
        for q in QUEUE'range loop 
            if (q_val(q) = FALSE) then
                for i in i_val'range loop
                    if (q-i-1 >= QUEUE'low) then
                        if (q_val(q-i-1)) then
                            i_val(i) := '1';
                        else
                            i_val(i) := '0';
                        end if;
                    else
                            i_val(i) := '1';
                    end if;
                end loop;
                i_sel := priority_selector(i_val);
                result(q) := select_word(WORDS=>i_vec, SEL=>i_sel);
            else
                result(q) := QUEUE(q);
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief O_SHIFT信号からONE-HOTのセレクト信号を生成する関数.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- 例) SHIFT(3 downto 0)="0000" => SEL(0 to 4)=(0=>'1',1=>'0',2=>'0',3=>'0',4=>'0')
    --     SHIFT(3 downto 0)="0001" => SEL(0 to 4)=(0=>'0',1=>'1',2=>'0',3=>'0',4=>'0')
    --     SHIFT(3 downto 0)="0011" => SEL(0 to 4)=(0=>'0',1=>'0',2=>'1',3=>'0',4=>'0')
    --     SHIFT(3 downto 0)="0111" => SEL(0 to 4)=(0=>'0',1=>'0',2=>'0',3=>'1',4=>'0')
    --     SHIFT(3 downto 0)="1111" => SEL(0 to 4)=(0=>'0',1=>'0',2=>'0',3=>'0',4=>'1')
    -------------------------------------------------------------------------------
    function  shift_to_selector(
                 SHIFT   :  std_logic_vector;
                 MIN     :  integer;
                 MAX     :  integer
    )            return     std_logic_vector
    is
        variable result  :  std_logic_vector(MIN to MAX);
    begin
        for i in result'range loop
            if    (i < SHIFT'low ) then
                    result(i) := '0';
            elsif (i = SHIFT'low ) then
                if (SHIFT(i) = '0') then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            elsif (i <= SHIFT'high) then
                if (SHIFT(i) = '0' and SHIFT(i-1) = '1') then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            elsif (i = SHIFT'high+1) then
                if (SHIFT(i-1) = '1') then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            else
                    result(i) := '0';
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ワード配列の有効なデータをLOW側に詰めたワード配列を求める関数.
    -------------------------------------------------------------------------------
    function  justify_words(
                 WORDS   :  WORD_VECTOR
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_val   :  std_logic_vector(0 to WORDS'length-1);
        variable s_vec   :  WORD_VECTOR     (0 to WORDS'length-1);
        variable s_sel   :  std_logic_vector(0 to WORDS'length-1);
        variable result  :  WORD_VECTOR     (0 to WORDS'length-1);
    begin
        for i in i_vec'range loop
            if (i_vec(i).VAL) then
                i_val(i) := '1';
            else
                i_val(i) := '0';
            end if;
        end loop;
        s_sel := priority_selector(i_val);
        for i in result'range loop
            result(i) := select_word(
                WORDS => i_vec(i to WORDS'length-1  ),
                SEL   => s_sel(0 to WORDS'length-i-1)
            );
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューを指定した分だけLOW側にシフトした新しいキューを求める関数.
    -------------------------------------------------------------------------------
    function  shift_words(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_sel   :  std_logic_vector(0 to SHIFT'high  +1);
        variable result  :  WORD_VECTOR     (0 to WORDS'length-1);
    begin
        i_sel := shift_to_selector(SHIFT, i_sel'low, i_sel'high);
        for i in result'range loop
            result(i) := select_word(
                WORDS => i_vec(i to minimum(i+i_sel'high,i_vec'high)),
                SEL   => i_sel
            );
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューから指定した分だけキューに残して残りを削除したキューを求める関数.
    -------------------------------------------------------------------------------
    function  flush_words(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     WORD_VECTOR
    is
        alias    i_vec   :  WORD_VECTOR(0 to WORDS'length-1) is WORDS;
        variable result  :  WORD_VECTOR(0 to WORDS'length-1);
    begin
        for i in result'range loop
            if    (i <  SHIFT'low ) then
                result(i).VAL := i_vec(i).VAL;
            elsif (i <= SHIFT'high) then
                result(i).VAL := i_vec(i).VAL and (SHIFT(i) = '1');
            else
                result(i).VAL := FALSE;
            end if;
            result(i).DATA := (others => '0');
            result(i).STRB := (others => '0');
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューに入っているワード数がSHIFTで指定された数未満かどうかを求める関数
    -------------------------------------------------------------------------------
    function  words_less_than_shift_size(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     boolean
    is
        alias    i_vec   :  WORD_VECTOR(0 to WORDS'length-1) is WORDS;
        variable result  :  boolean;
    begin
        result := FALSE;
        for i in SHIFT'high downto i_vec'low loop
            if (i < SHIFT'low) then
                if (i_vec(i).VAL = FALSE) then
                    result := TRUE;
                end if;
            else
                if (i_vec(i).VAL = FALSE and SHIFT(i) = '1') then
                    result := TRUE;
                end if;
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューに入っているワード数がSHIFTで指定された数を越えているかどうかを求める関数
    -------------------------------------------------------------------------------
    function  words_more_than_shift_size(
                 WORDS   :  WORD_VECTOR;
                 SHIFT   :  std_logic_vector
    )            return     boolean
    is
        alias    i_vec   :  WORD_VECTOR     (0 to WORDS'length-1) is WORDS;
        variable i_sel   :  std_logic_vector(0 to SHIFT'high  +1);
        variable result  :  boolean;
    begin
        i_sel  := shift_to_selector(SHIFT, i_sel'low, i_sel'high);
        result := FALSE;
        for i in i_vec'range loop
            if (i_sel'low <= i and i <= i_sel'high) then
                if (i_sel(i) = '1' and i_vec(i).VAL) then
                    result := TRUE;
                end if;
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --! @brief キューのサイズを計算する関数.
    -------------------------------------------------------------------------------
    function  QUEUE_DEPTH return integer is begin
        if (QUEUE_SIZE > 0) then
            if (QUEUE_SIZE >= O_WIDTH+I_WIDTH-1) then
                return QUEUE_SIZE;
            else
                assert (QUEUE_SIZE >= I_WIDTH+O_WIDTH-1)
                    report "require QUEUE_SIZE >= I_WIDTH+O_WIDTH-1" severity WARNING;
                return O_WIDTH+I_WIDTH-1;
            end if;
        else
                return O_WIDTH+I_WIDTH+I_WIDTH-1;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 現在のキューの状態.
    -------------------------------------------------------------------------------
    signal    curr_queue    : WORD_VECTOR(0 to QUEUE_DEPTH-1);
    -------------------------------------------------------------------------------
    --! @brief 1ワード分のイネーブル信号がオール0であることを示す定数.
    -------------------------------------------------------------------------------
    constant  STRB_NULL     : std_logic_vector(STRB_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --! @brief FLUSH 出力フラグ.
    -------------------------------------------------------------------------------
    signal    flush_output  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief FLUSH 保留フラグ.
    -------------------------------------------------------------------------------
    signal    flush_pending : std_logic;
    -------------------------------------------------------------------------------
    --! @brief DONE 出力フラグ.
    -------------------------------------------------------------------------------
    signal    done_output   : std_logic;
    -------------------------------------------------------------------------------
    --! @brief DONE 保留フラグ.
    -------------------------------------------------------------------------------
    signal    done_pending  : std_logic;
    -------------------------------------------------------------------------------
    --! @brief O_VAL信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    o_valid       : std_logic;
    -------------------------------------------------------------------------------
    --! @brief I_RDY信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    i_ready       : std_logic;
    -------------------------------------------------------------------------------
    --! @brief BUSY信号を内部で使うための信号.
    -------------------------------------------------------------------------------
    signal    curr_busy     : std_logic;
begin
    -------------------------------------------------------------------------------
    -- メインプロセス
    -------------------------------------------------------------------------------
    process (CLK, RST) 
        variable    in_words          : WORD_VECTOR(0 to I_WIDTH-1);
        variable    next_queue        : WORD_VECTOR(curr_queue'range);
        variable    next_valid_output : boolean;
        variable    next_flush_output : std_logic;
        variable    next_flush_pending: std_logic;
        variable    next_flush_fall   : std_logic;
        variable    next_done_output  : std_logic;
        variable    next_done_pending : std_logic;
        variable    next_done_fall    : std_logic;
        variable    pending_flag      : boolean;
        variable    flush_output_done : boolean;
        variable    flush_output_last : boolean;
    begin
        if (RST = '1') then
                curr_queue    <= (others => WORD_NULL);
                flush_output  <= '0';
                flush_pending <= '0';
                done_output   <= '0';
                done_pending  <= '0';
                i_ready       <= '0';
                o_valid       <= '0';
                curr_busy     <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_queue    <= (others => WORD_NULL);
                flush_output  <= '0';
                flush_pending <= '0';
                done_output   <= '0';
                done_pending  <= '0';
                i_ready       <= '0';
                o_valid       <= '0';
                curr_busy     <= '0';
            else
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態を示す変数に現在のキューの状態をセット.
                -------------------------------------------------------------------
                next_queue := curr_queue;
                -------------------------------------------------------------------
                -- キュー初期化時は、OFFSETで指定された分だけ、あらかじめキューに
                -- ダミーのデータを入れておく.
                -------------------------------------------------------------------
                if (START = '1') then
                    for i in next_queue'range loop
                        if (i < O_WIDTH-1) then
                            next_queue(i).VAL := (OFFSET(i) = '1');
                        else
                            next_queue(i).VAL := FALSE;
                        end if;
                        next_queue(i).DATA := (others => '0');
                        next_queue(i).STRB := (others => '0');
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- データ入力時は、キューに入力されたワードを追加する.
                -------------------------------------------------------------------
                if (I_VAL = '1' and i_ready = '1') then
                    for i in in_words'range loop
                        in_words(i).DATA :=  I_DATA((i+1)*WORD_BITS-1 downto i*WORD_BITS);
                        in_words(i).STRB :=  I_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS);
                        in_words(i).VAL  := (I_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS) /= STRB_NULL);
                    end loop;
                    if (I_JUSTIFIED     = 0) and
                       (in_words'length > 1) then
                        in_words := justify_words(in_words);
                    end if;
                    next_queue := append_words(next_queue, in_words);
                end if;
                -------------------------------------------------------------------
                -- データ出力時は、キューの先頭からO_SHIFTで指定された分だけ、
                -- データを取り除く.
                -------------------------------------------------------------------
                if (o_valid = '1' and O_RDY = '1') then
                    if (FLUSH_ENABLE >  0 ) and
                       (flush_output = '1') then
                        flush_output_last :=     words_less_than_shift_size(next_queue, O_SHIFT);
                        flush_output_done := not words_more_than_shift_size(next_queue, O_SHIFT);
                    else
                        flush_output_last := FALSE;
                        flush_output_done := FALSE;
                    end if;
                    if (flush_output_last) then
                        next_queue := flush_words(next_queue, O_SHIFT);
                    else
                        next_queue := shift_words(next_queue, O_SHIFT);
                    end if;
                else
                        flush_output_last := FALSE;
                        flush_output_done := FALSE;
                end if;
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態をレジスタに保持
                -------------------------------------------------------------------
                curr_queue <= next_queue;
                -------------------------------------------------------------------
                -- 次のクロックでのキューの状態でO_WIDTHの位置にデータが入って
                -- いるか否かをチェック.
                -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                -- この位置にデータがある場合は、O_DONE、O_FLUSH はまだアサートせ
                -- ずに、一旦ペンディングしておく.
                -------------------------------------------------------------------
                if (next_queue'high >= O_WIDTH) then
                    pending_flag := (next_queue(O_WIDTH).VAL);
                else
                    pending_flag := FALSE;
                end if;
                -------------------------------------------------------------------
                -- FLUSH制御
                -------------------------------------------------------------------
                if    (FLUSH_ENABLE = 0) then
                        next_flush_output  := '0';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                elsif (flush_output = '1') then
                    if (flush_output_done) then
                        next_flush_output  := '0';
                        next_flush_pending := '0';
                        next_flush_fall    := '1';
                    else
                        next_flush_output  := '1';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                    end if;
                elsif (flush_pending = '1') or
                      (FLUSH         = '1') or
                      (I_VAL = '1' and i_ready = '1' and I_FLUSH = '1') then
                    if (pending_flag) then
                        next_flush_output  := '0';
                        next_flush_pending := '1';
                        next_flush_fall    := '0';
                    else
                        next_flush_output  := '1';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                    end if;
                else
                        next_flush_output  := '0';
                        next_flush_pending := '0';
                        next_flush_fall    := '0';
                end if;
                flush_output  <= next_flush_output;
                flush_pending <= next_flush_pending;
                -------------------------------------------------------------------
                -- DONE制御
                -------------------------------------------------------------------
                if    (done_output = '1') then
                    if (next_queue(next_queue'low).VAL = FALSE) then
                        next_done_output   := '0';
                        next_done_pending  := '0';
                        next_done_fall     := '1';
                    else
                        next_done_output   := '1';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                    end if;
                elsif (done_pending = '1') or
                      (DONE         = '1') or
                      (I_VAL = '1' and i_ready = '1' and I_DONE = '1') then
                    if (pending_flag) then
                        next_done_output   := '0';
                        next_done_pending  := '1';
                        next_done_fall     := '0';
                    else
                        next_done_output   := '1';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                    end if;
                else
                        next_done_output   := '0';
                        next_done_pending  := '0';
                        next_done_fall     := '0';
                end if;
                done_output   <= next_done_output;
                done_pending  <= next_done_pending;
                -------------------------------------------------------------------
                -- 出力有効信号の生成.
                -------------------------------------------------------------------
                if (O_VAL_SIZE = 0) then
                    next_valid_output := next_queue(O_WIDTH   -1).VAL;
                else
                    next_valid_output := next_queue(O_VAL_SIZE-1).VAL;
                end if;
                if (O_ENABLE = '1') and
                   ((next_done_output  = '1') or
                    (next_flush_output = '1') or
                    (next_valid_output = TRUE)) then
                    o_valid <= '1';
                else
                    o_valid <= '0';
                end if;
                -------------------------------------------------------------------
                -- 入力可能信号の生成.
                -------------------------------------------------------------------
                if (I_ENABLE = '1') and 
                   (next_done_output  = '0' and next_done_pending  = '0') and
                   (next_flush_output = '0' and next_flush_pending = '0') and
                   (next_queue(next_queue'length-I_WIDTH).VAL = FALSE) then
                    i_ready <= '1';
                else
                    i_ready <= '0';
                end if;
                -------------------------------------------------------------------
                -- 現在処理中であることを示すフラグ.
                -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                -- 最初に入力があった時点で'1'になり、O_DONEまたはO_FLUSHが出力完了
                -- した時点で'0'になる。
                -------------------------------------------------------------------
                if (curr_busy = '1') then
                    if (next_flush_fall = '1') or
                       (next_done_fall  = '1') then
                        curr_busy <= '0';
                    else
                        curr_busy <= '1';
                    end if;
                else
                    if (I_VAL = '1' and i_ready = '1') then
                        curr_busy <= '1';
                    else
                        curr_busy <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 各種出力信号の生成.
    -------------------------------------------------------------------------------
    O_FLUSH <= flush_output when(FLUSH_ENABLE > 0) else '0';
    O_DONE  <= done_output;
    O_VAL   <= o_valid;
    I_RDY   <= i_ready;
    BUSY    <= curr_busy;
    process (curr_queue) begin
        for i in 0 to O_WIDTH-1 loop
            O_DATA((i+1)*WORD_BITS-1 downto i*WORD_BITS) <= curr_queue(i).DATA;
            O_STRB((i+1)*STRB_BITS-1 downto i*STRB_BITS) <= curr_queue(i).STRB;
        end loop;
        for i in VALID'range loop
            if (curr_queue'low <= i and i <= curr_queue'high) then
                if (curr_queue(i).VAL) then
                    VALID(i) <= '1';
                else
                    VALID(i) <= '0';
                end if;
            else
                    VALID(i) <= '0';
            end if;
        end loop;
    end process;
end RTL;
