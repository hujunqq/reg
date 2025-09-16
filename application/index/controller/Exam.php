<?php

namespace app\index\controller;

use app\common\controller\Frontend;
use app\common\model\Exam as ExamModel;

class Exam extends Frontend
{

    protected $noNeedLogin = '';
    protected $noNeedRight = '*';

    public function index()
    {
        $examList = ExamModel::where('start_time', '<=', date('Y-m-d H:i:s'))
            ->where('end_time', '>=', date('Y-m-d H:i:s'))
            ->select();
        $this->view->assign('examList', $examList);
        return $this->view->fetch();
    }

    public function detail($id = null)
    {
        $exam = ExamModel::get($id);
        if (!$exam) {
            $this->error(__('No results were found'));
        }
        $examLevelList = \app\common\model\ExamLevel::where('exam_id', $id)->select();
        $this->view->assign('exam', $exam);
        $this->view->assign('examLevelList', $examLevelList);
        return $this->view->fetch();
    }

    public function apply($level_id = null)
    {
        $this->request->isPost() and $this->token();
        $level = \app\common\model\ExamLevel::get($level_id);
        if (!$level) {
            $this->error(__('No results were found'));
        }
        $exam = \app\common\model\Exam::get($level->exam_id);
        if (!$exam) {
            $this->error(__('No results were found'));
        }
        $user = $this->auth->getUser();
        // 检查用户资料是否完整
        $required_fields = ['id_card_number', 'id_card_front_image', 'id_card_back_image', 'current_occupation', 'company_name', 'work_experience_years'];
        foreach ($required_fields as $field) {
            if (empty($user[$field])) {
                $this->error(__('请先完善您的个人资料'), url('user/profile'));
            }
        }

        $application = \app\common\model\ExamApplication::where('user_id', $user->id)->where('exam_id', $exam->id)->find();
        if ($application) {
            if ($application->status == 'rejected' && $exam->allow_reapply_on_fail) {
                // 重新提交
                $application->status = 'pending';
                $application->apply_time = date('Y-m-d H:i:s');
                $application->exam_level_id = $level_id; // 更新级别
                $application->save();
                $this->success(__('重新提交成功'));
            } else {
                $this->error(__('您已经报名过此考试'));
            }
        }

        $data = [
            'user_id'       => $user->id,
            'exam_id'       => $exam->id,
            'exam_level_id' => $level_id,
            'status'        => 'pending',
            'apply_time'    => date('Y-m-d H:i:s'),
        ];
        \app\common\model\ExamApplication::create($data);
        $this->success(__('报名成功'));
    }
}
