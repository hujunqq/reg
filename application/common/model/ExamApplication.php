<?php

namespace app\common\model;

use think\Model;

class ExamApplication extends Model
{
    // 表名
    protected $name = 'exam_application';

    // 自动写入时间戳字段
    protected $autoWriteTimestamp = 'int';

    // 定义时间戳字段名
    protected $createTime = 'createtime';
    protected $updateTime = 'updatetime';

    // 追加属性
    protected $append = [

    ];

    public function user()
    {
        return $this->belongsTo('app\common\model\User', 'user_id', 'id', [], 'LEFT')->setEagerlyType(0);
    }

    public function exam()
    {
        return $this->belongsTo('app\common\model\Exam', 'exam_id', 'id', [], 'LEFT')->setEagerlyType(0);
    }

    public function examlevel()
    {
        return $this->belongsTo('app\common\model\ExamLevel', 'exam_level_id', 'id', [], 'LEFT')->setEagerlyType(0);
    }
}
