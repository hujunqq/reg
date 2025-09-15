define(['jquery', 'bootstrap', 'backend', 'table', 'form'], function ($, undefined, Backend, Table, Form) {

    var Controller = {
        index: function () {
            // 初始化表格参数配置
            Table.api.init({
                extend: {
                    index_url: 'exam/application/index' + location.search,
                    add_url: 'exam/application/add',
                    edit_url: 'exam/application/edit',
                    del_url: 'exam/application/del',
                    multi_url: 'exam/application/multi',
                    import_url: 'exam/application/import',
                    table: 'exam_application',
                }
            });

            var table = $("#table");

            // 初始化表格
            table.bootstrapTable({
                url: $.fn.bootstrapTable.defaults.extend.index_url,
                pk: 'id',
                sortName: 'id',
                columns: [
                    [
                        {checkbox: true},
                        {field: 'id', title: __('Id')},
                        {field: 'user.username', title: __('User.username')},
                        {field: 'exam.name', title: __('Exam.name')},
                        {field: 'examlevel.level_name', title: __('Examlevel.level_name')},
                        {field: 'status', title: __('Status'), searchList: {"pending":__('pending'),"approved":__('approved'),"rejected":__('rejected')}, formatter: Table.api.formatter.status},
                        {field: 'score', title: __('Score')},
                        {field: 'admission_status', title: __('Admission_status'), searchList: {"passed":__('passed'),"failed":__('failed')}, formatter: Table.api.formatter.status},
                        {field: 'apply_time', title: __('Apply_time'), operate:'RANGE', addclass:'datetimerange', formatter: Table.api.formatter.datetime},
                        {field: 'audit_time', title: __('Audit_time'), operate:'RANGE', addclass:'datetimerange', formatter: Table.api.formatter.datetime},
                        {
                            field: 'operate',
                            title: __('Operate'),
                            table: table,
                            events: Table.api.events.operate,
                            buttons: [
                                {
                                    name: 'approve',
                                    text: __('Approve'),
                                    icon: 'fa fa-check',
                                    classname: 'btn btn-xs btn-success btn-ajax',
                                    url: 'exam/application/approve',
                                    confirm: 'Are you sure to approve this application?',
                                    success: function (data, ret) {
                                        table.bootstrapTable('refresh');
                                    },
                                    visible: function (row) {
                                        return row.status == 'pending';
                                    }
                                },
                                {
                                    name: 'reject',
                                    text: __('Reject'),
                                    icon: 'fa fa-times',
                                    classname: 'btn btn-xs btn-danger btn-ajax',
                                    url: 'exam/application/reject',
                                    confirm: 'Are you sure to reject this application?',
                                    success: function (data, ret) {
                                        table.bootstrapTable('refresh');
                                    },
                                    visible: function (row) {
                                        return row.status == 'pending';
                                    }
                                }
                            ],
                            formatter: Table.api.formatter.operate
                        }
                    ]
                ]
            });

            // 为表格绑定事件
            Table.api.bindevent(table);

            // 绑定事件
            $(document).on("click", ".btn-import", function () {
                var url = $(this).data("url");
                var id = $(this).data("id");
                Fast.api.open(url + (id ? "/ids/" + id : ""), __('Import'));
            });

            // 绑定TAB事件
            $('.panel-heading a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
                var field = $(this).closest(".panel-heading").data("field");
                var value = $(this).data("value");
                var options = table.bootstrapTable('getOptions');
                options.pageNumber = 1;
                options.queryParams = function (params) {
                    var filter = {};
                    if (field) {
                        filter[field] = value;
                    }
                    params.filter = JSON.stringify(filter);
                    return params;
                };
                table.bootstrapTable('refresh', {});
                return false;
            });
        },
        add: function () {
            Controller.api.bindevent();
        },
        edit: function () {
            Controller.api.bindevent();
        },
        api: {
            bindevent: function () {
                Form.api.bindevent($("form[role=form]"));
            }
        }
    };
    return Controller;
});
