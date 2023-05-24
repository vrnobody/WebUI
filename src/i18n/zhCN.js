export default {
    servers: '服务器',
    import: '导入',
    settings: '配置',
    about: '关于',

    //theme
    lightTheme: '亮主题',
    darkTheme: '暗主题',
    system: '跟随系统',

    // server
    selectAll: '全选',
    selectTimeout: '选中超时',
    invertSelection: '反选',
    curPage: '当前页',
    global: '全局',
    viewLogs: '查看日志',
    copied: '已复制',
    copy: '复制',
    count: '计数',
    selected: '选中',
    custom: '自定义',
    inbMode: 'Inbound模式',
    inbIp: 'Inbound IP',
    inbPort: 'Inbound端口',
    sortSelectedByLatency: '按测速排序',
    sortSelectedByModifyTime: '按最近修改时间排序',
    sortSelectedBySummary: '按摘要排序',
    newConfig: '添加Config',

    // luna
    name: '名字',
    replaceCurScript: '替换当前未保存的脚本？',
    emptyCurScript: '清空当前未保存的脚本？',
    none: '无',
    confirmRemoveCore: '确定要删除 [{name}] 吗？',
    hidden: '隐藏',
    autorun: '自启动',
    loadClr: '加载CLR',
    editor: '编辑器',
    manager: '管理器',
    vars: '变量',
    funcs: '函数',
    newScript: '新脚本',
    loadFile: '从文件加载',
    saveAs: '另存为文件',
    load: '加载',
    file: '文件',
    extensions: '扩展名',

    shareLinks: '分享链接',
    subscriptions: '订阅',
    nNewServerImported: `导入了{count}个服务器。`,
    mark: '标记',
    remark: '备注',
    tag1: '标签1',
    tag2: '标签2',
    tag3: '标签3',
    scanQrCode: '扫描二维码',
    enable: '启用',
    update: '更新',
    updating: '更新中...',
    confirmRemoveSub: '删除订阅 [{name}]？',
    alias: '别名',


    status: '状态',
    select: '选择',
    index: '序号',
    title: '标题',
    summary: '摘要',
    tags: '标签',
    controls: '控制',
    loading: '加载中...',

    jump: '跳转',

    search: '搜索',

    server_ver_not_supported: `server.lua v{curVer}不受支持！\n请更新到v{expectedVer}。`,
    please_update_app: `请更新V2RayGCon v{curVer}至v{expectedVer}+`,

    add: '添加',
    save: "保存",
    close: "关闭",

    listIsEmpty: '列表为空',
    confirmDeleteNServers: `确定删除{count}个服务器吗？`,
    yes: '是',
    no: '否',
    serversDeleted: '服务器已删除！',
    deleteFailed: '删除失败!',
    noServerSelected: '没选中任何服务器！',

    success: '成功',
    failed: '失败',
    error: '错误',
    ok: 'Ok',
    done: '完成',

    // settings
    key: '键名',
    value: '值',
    'maxConcurrentCore': '并发core数量',
    'enableUTlsfingerprint': '启用自定义uTLS指纹',
    'uTlsFingerprint': '自定义uTLS指纹',
    'enableUserAgent': '启用自定义user agent',
    'userAgent': '自定义user agent',
    'enableSpeedtestSettings': '启用自定义测速设定',
    'speedtestUrl': '测速URL',
    'speedtestTimeout': '测速超时(ms)',
    'speedtestSize': '测速大小(KiB)',
    'speettestCycles': '测速次数',
    'quickSwitchLantency': '快速切换延迟(ms)',
    'importTrojan': '导入trojan://...',
    'importShadowsocks': '导入ss://...',
    'importMode': '导入模式(1.HTTP, 2.SOCKS)',
    'importIp': '默认导入IP',
    'importPort': '默认导入端口',

    // server errors
    configIsEmpty: 'config为空！',
    addServerFailed: '添加服务器失败！',
    serverNotFound: '查找服务器失败！',

    sendReqError: '发送请求错误！',
    parseReqError: '解释请求错误！',
    parseRespError: '解释回复错误！',
    funcNotExists: '函数不存在！',
    paramIsNotTable: '参数不是一个列表！',
    callFuncError: '执行函数时发生错误！',
    callbackFuncError: '回调函数错误！',
}