define(['jquery', 'bootstrap', 'backend', 'table', 'form'], function ($, undefined, Backend, Table, Form) {

    var Controller = {
        index: function () {
            // 初始化表格参数配置
            Table.api.init({
                extend: {
                    index_url: 'exam/level/index' + location.search,
                    add_url: 'exam/level/add',
                    edit_url: 'exam/level/edit',
                    del_url: 'exam/level/del',
                    multi_url: 'exam/level/multi',
                    table: 'exam_level',
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
                        {field: 'exam_id', title: __('Exam_id')},
                        {field: 'level_name', title: __('Level_name'), searchList: {"研究馆员":__('研究馆员'),"副研究馆员":__('副研究馆员'),"馆员":__('馆员'),"助理馆员":__('助理馆员'),"管理员":__('管理员')}, formatter: Table.api.formatter.normal},
                        {field: 'passing_score', title: __('Passing_score')},
                        {field: 'ticket_code', title: __('Ticket_code')},
                        {field: 'createtime', title: __('Createtime'), operate:'RANGE', addclass:'datetimerange', formatter: Table.api.formatter.datetime},
                        {field: 'updatetime', title: __('Updatetime'), operate:'RANGE', addclass:'datetimerange', formatter: Table.api.formatter.datetime},
                        {field: 'operate', title: __('Operate'), table: table, events: Table.api.events.operate, formatter: Table.api.formatter.operate}
                    ]
                ]
            });

            // 为表格绑定事件
            Table.api.bindevent(table);
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
