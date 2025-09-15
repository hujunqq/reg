<?php

namespace app\admin\controller\exam;

use app\common\controller\Backend;

/**
 * 报名申请管理
 *
 * @icon fa fa-file-text-o
 */
class Application extends Backend
{

    /**
     * Application模型对象
     * @var \app\admin\model\exam\Application
     */
    protected $model = null;

    public function _initialize()
    {
        parent::_initialize();
        $this->model = new \app\admin\model\exam\Application;
    }

    /**
     * 默认生成的控制器所继承的父类中有index/add/edit/del/multi五个基础方法、destroy/restore/recyclebin三个回收站方法
     * 因此在当前控制器中可不用编写增删改查的代码,除非需要自己控制这部分逻辑
     * 需要将application/admin/library/traits/Backend.php中对应的方法复制到当前控制器,然后进行修改
     */

    public function downloadtemplate($ids = null)
    {
        $exam_id = $ids;
        if (!$exam_id) {
            $this->error(__('Parameter %s can not be empty', 'ids'));
        }

        $applications = \app\common\model\ExamApplication::where('exam_id', $exam_id)
            ->where('status', 'approved')
            ->with(['user'])
            ->select();

        $spreadsheet = new \PhpOffice\PhpSpreadsheet\Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setCellValue('A1', '姓名');
        $sheet->setCellValue('B1', '身份证号');
        $sheet->setCellValue('C1', '手机号');
        $sheet->setCellValue('D1', '考试ID');
        $sheet->setCellValue('E1', '分数');

        $row = 2;
        foreach ($applications as $app) {
            $sheet->setCellValue('A' . $row, $app->user->nickname);
            $sheet->setCellValue('B' . $row, $app->user->id_card_number);
            $sheet->setCellValue('C' . $row, $app->user->mobile);
            $sheet->setCellValue('D' . $row, $app->exam_id);
            $sheet->setCellValue('E' . $row, ''); // Empty score column
            $row++;
        }

        $writer = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);
        $filename = 'score_template_' . $exam_id . '.xlsx';
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $filename . '"');
        header('Cache-Control: max-age=0');
        $writer->save('php://output');
        exit;
    }

    public function edit($ids = null)
    {
        $row = $this->model->get($ids);
        if (!$row) {
            $this->error(__('No Results were found'));
        }
        $adminIds = $this->getDataLimitAdminIds();
        if (is_array($adminIds) && !in_array($row[$this->dataLimitField], $adminIds)) {
            $this->error(__('You have no permission'));
        }
        if (false === $this->request->isPost()) {
            $this->view->assign('row', $row);
            return $this->view->fetch();
        }
        $params = $this->request->post('row/a');
        if (empty($params)) {
            $this->error(__('Parameter %s can not be empty', ''));
        }
        $params = $this->preExcludeFields($params);

        // 自动判断录取状态
        if (isset($params['score'])) {
            $level = \app\admin\model\exam\Level::get($row->exam_level_id);
            if ($level && $params['score'] >= $level->passing_score) {
                $params['admission_status'] = 'passed';
            } else {
                $params['admission_status'] = 'failed';
            }
        }

        $result = false;
        \think\Db::startTrans();
        try {
            //是否采用模型验证
            if ($this->modelValidate) {
                $name = str_replace("\\model\\", "\\validate\\", get_class($this->model));
                $validate = is_bool($this->modelValidate) ? ($this->modelSceneValidate ? $name . '.edit' : $name) : $this->modelValidate;
                $row->validateFailException()->validate($validate);
            }
            $result = $row->allowField(true)->save($params);
            \think\Db::commit();
        } catch (\think\exception\ValidateException $e) {
            \think\Db::rollback();
            $this->error($e->getMessage());
        } catch (\think\exception\PDOException $e) {
            \think\Db::rollback();
            $this->error($e->getMessage());
        } catch (\Exception $e) {
            \think\Db::rollback();
            $this->error($e->getMessage());
        }
        if (false === $result) {
            $this->error(__('No rows were updated'));
        }
        $this->success();
    }

    public function approve($ids = null)
    {
        $row = $this->model->get($ids);
        if (!$row) {
            $this->error(__('No Results were found'));
        }
        if ($row->status != 'pending') {
            $this->error(__('This application has been processed'));
        }
        $row->status = 'approved';
        $row->audit_time = date('Y-m-d H:i:s');
        $row->save();
        $this->success(__('Approve successful'));
    }

    public function reject($ids = null)
    {
        $row = $this->model->get($ids);
        if (!$row) {
            $this->error(__('No Results were found'));
        }
        if ($row->status != 'pending') {
            $this->error(__('This application has been processed'));
        }
        $row->status = 'rejected';
        $row->audit_time = date('Y-m-d H:i:s');
        $row->save();
        $this->success(__('Reject successful'));
    }

    public function import()
    {
        $file = $this->request->file('file');
        if (!$file) {
            $this->error(__('Parameter %s can not be empty', 'file'));
        }
        $filePath = $file->getRealPath();
        $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($filePath);
        $worksheet = $spreadsheet->getActiveSheet();
        $data = [];
        foreach ($worksheet->getRowIterator() as $row) {
            $rowData = [];
            $cellIterator = $row->getCellIterator();
            $cellIterator->setIterateOnlyExistingCells(FALSE);
            foreach ($cellIterator as $cell) {
                $rowData[] = $cell->getValue();
            }
            $data[] = $rowData;
        }

        $succ_result = 0;
        $err_result = 0;
        //从第二行开始处理数据
        for ($i = 1; $i < count($data); $i++) {
            $row = $data[$i];
            $id_card_number = $row[1]; // Index updated
            $mobile = $row[2]; // Index updated
            $exam_id = $row[3]; // New column
            $score = $row[4]; // New column index

            $user = \app\common\model\User::where(['id_card_number' => $id_card_number, 'mobile' => $mobile])->find();
            if ($user) {
                $application = $this->model->where('user_id', $user->id)->where('exam_id', $exam_id)->find(); // Added exam_id to the query
                if ($application) {
                    $application->score = $score;

                    // 自动判断录取状态
                    $level = \app\admin\model\exam\Level::get($application->exam_level_id);
                    if ($level && $score >= $level->passing_score) {
                        $application->admission_status = 'passed';
                    } else {
                        $application->admission_status = 'failed';
                    }

                    $application->save();
                    $succ_result++;
                } else {
                    $err_result++;
                }
            } else {
                $err_result++;
            }
        }

        $this->success(__('Succeed: %s,Fail: %s', $succ_result, $err_result));
    }

}
