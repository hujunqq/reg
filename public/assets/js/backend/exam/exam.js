define(['jquery', 'bootstrap', 'backend', 'table', 'form'], function ($, undefined, Backend, Table, Form) {

    var Controller = {
        index: function () {
            // 初始化表格参数配置
            Table.api.init({
                extend: {
                    index_url: 'exam/exam/index' + location.search,
                    add_url: 'exam/exam/add',
                    edit_url: 'exam/exam/edit',
                    del_url: 'exam/exam/del',
                    multi_url: 'exam/exam/multi',
                    table: 'exam',
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
                        {field: 'name', title: __('Name')},
                        {field: 'start_time', title: __('Start_time'), operate:'RANGE', addclass:'datetimerange', formatter: Table.api.formatter.datetime},
                        {field: 'end_time', title: __('End_time'), operate:'RANGE', addclass:'datetimerange', formatter: Table.api.formatter.datetime},
                        {field: 'year', title: __('Year')},
                        {field: 'exam_time', title: __('Exam_time'), operate:'RANGE', addclass:'datetimerange', formatter: Table.api.formatter.datetime},
                        {field: 'exam_location', title: __('Exam_location')},
                        {field: 'allow_reapply_on_fail', title: __('Allow_reapply_on_fail'), searchList: {"1":__('Yes'),"0":__('No')}, formatter: Table.api.formatter.status},
                        {field: 'allow_download_ticket', title: __('Allow_download_ticket'), searchList: {"1":__('Yes'),"0":__('No')}, formatter: Table.api.formatter.status},
                        {field: 'allow_download_certificate', title: __('Allow_download_certificate'), searchList: {"1":__('Yes'),"0":__('No')}, formatter: Table.api.formatter.status},
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
