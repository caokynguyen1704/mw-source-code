# scriptsupport API

mini.log('== python load start : base.py ==')


# 测试 test
# def testcall(content):
#    minilog("<py> -testcall-:" + str(content))
#    return ("<py> -testcall ret-",)

# 错误ID ErrorCode
ErrorCode = {
    "OK" : 0,
    "TIMEOUT" : 1000,
    "FAILED" : 1001,
    "NODE_NOT_VALID" : 1002,
    "OVERLOAD" : 1003,
    "DEBUG_ENOUGH" : 1004,
    "BUSY" : 1005,
    "NOT_IN_THREAD" : 1006,
}

# api 回调转任务处理(字典)
_API_Callback2Task_ = {
    "ScriptSupportEvent" : {
        "registerEvent" : "API_SSEventRegEvent",
    },
    "Player" : {
        "playAdvertisingCallback" : False,
    },
}

###########################################################################

# api
# param : module : str : api模块
# param : method : str : api方法
# param : vartuple : tuples : 不定参数
def miniapi(module, method, *vartuple):
    minilog('== python : miniapi ==', module, method)
    # "param to json"
    if not isinstance(module, str) or not isinstance(method, str):
        minilog('== python : miniapi error 1 ==')
        return (ErrorCode["FAILED"],)

    # for redefine
    methodcategory = _API_Callback2Task_.get(module)
    if methodcategory:
        newfuncname = methodcategory.get(method)
        if newfuncname:
            f = globals()[newfuncname]
            if callable(f):
                return f(*vartuple)
            minilog('== python : miniapi error 2 ==')
            return (ErrorCode["FAILED"],)

    jsonin = json.dumps(vartuple)
    if not isinstance(jsonin, str):
        minilog('== python : miniapi error 3 ==')
        return (ErrorCode["FAILED"],)

    jsonout = mini.api(module, method, jsonin)
    if not isinstance(jsonout, str):
        minilog('== python : miniapi error 4 ==')
        return (ErrorCode["FAILED"],)

    # "return vals json list"
    ret = json.loads(jsonout)
    if not isinstance(ret, list) and not isinstance(ret, tuple):
        minilog('== python : miniapi error 5 ==')
        return (ErrorCode["FAILED"],)

    return tuple(ret)

# 打印Log
# param : vartuple : tuples : 不定参数
def minilog(*vartuple):
    # "var ..."
    msg = ''
    for val in vartuple:
        if len(msg) > 0:
            msg = msg + ', '
        msg = msg + str(val)
    mini.log(msg)
    return (ErrorCode["OK"],)

###########################################################################

# 任务池(字典)
_Dict_Task_Pool_ = {}

# 内部任务计数(用于生成内部任务名称)
_Task_Core_Count_ = 0

# 生成内部任务名称
def makeCoreTaskName():
    global _Task_Core_Count_
    _Task_Core_Count_ += 1
    return "PyTask_" + str(_Task_Core_Count_)

# 注册任务
def miniRegTask(taskname, func):
    minilog('== python : miniRegTask ==', taskname, func)
    if not isinstance(taskname, str) or not callable(func):
        minilog('== python : miniRegTask error 1 ==')
        return (ErrorCode["FAILED"],)

    taskcategory = _Dict_Task_Pool_.get(taskname)
    if taskcategory:
        taskcategory.append(func)
    else:
        taskcategory = [func,]
        _Dict_Task_Pool_.setdefault(taskname, taskcategory)

    miniapi('Task', 'regPython', taskname)
    return (ErrorCode["OK"],)

# 发送任务
# param : taskname : str : 任务名称
# param : paramjson :  str : 参数，json传递
def miniSendTask(taskname, *vartuple):
    miniapi('Task', 'receive', taskname, *vartuple)
    return (ErrorCode["OK"],)

# 接受任务
# param : taskname : str : 任务名称
# param : paramjson :  str : 参数，json传递
def miniReceiveTask(taskname, paramjson):
    minilog('== python : miniReceiveTask ==', taskname, paramjson)
    if not isinstance(taskname, str) or not isinstance(paramjson, str):
        return (ErrorCode["FAILED"],)

    taskcategory = _Dict_Task_Pool_.get(taskname)
    if not taskcategory:
        minilog("== python : miniReceiveTask error 1 ==")
        return (ErrorCode["FAILED"],)

    param = json.loads(paramjson)
    param = list(param)
    if not param:
        minilog("== python : miniReceiveTask error 2 ==")
        return (ErrorCode["FAILED"],)

    for taskfunc in taskcategory:
        argcount = taskfunc.__code__.co_argcount
        if argcount == 0:
            # 不传参
            taskfunc()
        elif argcount < len(param):
            # 取数量截断
            taskfunc(*param[:argcount])
        elif argcount > len(param):
            # 使用None填充
            param.extend([None for idx in range(argcount - len(param))])
            taskfunc(*param)
        else:
            # 正常传参
            taskfunc(*param)

    # _Dict_Task_Pool_.pop(taskname)
    return (ErrorCode["OK"],)

###########################################################################

# 触发器相关
def API_SSEventRegEvent(eventname, callback):
    taskname = makeCoreTaskName()
    miniRegTask(taskname, callback)
    miniapi("Task", "registerEvent", eventname, taskname)
    return

###########################################################################


mini.log('== python load OK : base.py ==')
