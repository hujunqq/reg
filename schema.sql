-- Add new columns to fa_user table
ALTER TABLE `fa_user`
ADD COLUMN `id_card_number` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '身份证号',
ADD COLUMN `id_card_front_image` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '身份证正面照',
ADD COLUMN `id_card_back_image` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '身份证反面照',
ADD COLUMN `degree_certificate_full_time` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '全日制学历或学位图',
ADD COLUMN `degree_certificate_part_time` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '在职学历或学位图',
ADD COLUMN `application_form` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '水测报名表',
ADD COLUMN `education_full_time_details` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '全日制教育毕业院校系及专业',
ADD COLUMN `education_part_time_details` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '在职教育毕业院校系及专业',
ADD COLUMN `current_occupation` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '现从事工作',
ADD COLUMN `supervisor_unit` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '主管单位',
ADD COLUMN `company_name` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '单位名称',
ADD COLUMN `administrative_duties` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '行政职务',
ADD COLUMN `work_experience_years` INT NOT NULL DEFAULT 0 COMMENT '工作年限',
ADD COLUMN `company_zip_code` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '单位邮编',
ADD COLUMN `company_phone` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '单位电话',
ADD COLUMN `company_address` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '单位地址',
ADD COLUMN `remarks` TEXT COMMENT '备注信息';

-- Create fa_exam table
CREATE TABLE `fa_exam` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '科目名称',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '截止时间',
  `year` varchar(255) NOT NULL DEFAULT '' COMMENT '所属年份',
  `exam_time` datetime DEFAULT NULL COMMENT '考试时间',
  `exam_location` varchar(255) NOT NULL DEFAULT '' COMMENT '考试地点',
  `allow_reapply_on_fail` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核失败是否允许重复提交状态',
  `allow_download_ticket` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否允许下载准考证状态',
  `allow_download_certificate` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否允许下载合格证状态',
  `createtime` int(10) DEFAULT NULL,
  `updatetime` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试表';

-- Create fa_exam_level table
CREATE TABLE `fa_exam_level` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `exam_id` int(10) unsigned NOT NULL,
  `level_name` enum('研究馆员','副研究馆员','馆员','助理馆员','管理员') NOT NULL COMMENT '报名级别名称',
  `passing_score` int(11) NOT NULL DEFAULT '0' COMMENT '录取分数线',
  `ticket_code` varchar(255) NOT NULL DEFAULT '' COMMENT '准考证编码',
  `createtime` int(10) DEFAULT NULL,
  `updatetime` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `exam_id` (`exam_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试级别表';

-- Create fa_exam_application table
CREATE TABLE `fa_exam_application` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `exam_id` int(10) unsigned NOT NULL,
  `exam_level_id` int(10) unsigned NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending' COMMENT '审核状态',
  `score` int(11) DEFAULT NULL COMMENT '分数',
  `admission_status` enum('passed','failed') DEFAULT NULL COMMENT '录取状态',
  `apply_time` datetime DEFAULT NULL COMMENT '报名时间',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `createtime` int(10) DEFAULT NULL,
  `updatetime` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `exam_id` (`exam_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报名申请表';

-- Add menu for Exam Management
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('menu', 0, 'exam', '考试管理', 'fa fa-book', 200, 'normal');
SET @parent_id = LAST_INSERT_ID();
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('menu', @parent_id, 'exam/exam', '考试列表', 'fa fa-list', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('menu', @parent_id, 'exam/level', '级别列表', 'fa fa-list-ol', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('menu', @parent_id, 'exam/application', '报名列表', 'fa fa-file-text-o', 0, 'normal');

INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/exam'), 'exam/exam/index', '查看', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/exam'), 'exam/exam/add', '添加', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/exam'), 'exam/exam/edit', '编辑', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/exam'), 'exam/exam/del', '删除', 'fa fa-circle-o', 0, 'normal');

INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/level'), 'exam/level/index', '查看', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/level'), 'exam/level/add', '添加', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/level'), 'exam/level/edit', '编辑', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/level'), 'exam/level/del', '删除', 'fa fa-circle-o', 0, 'normal');

INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/index', '查看', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/add', '添加', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/edit', '编辑', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/del', '删除', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/import', '导入', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/approve', '审核通过', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/reject', '审核拒绝', 'fa fa-circle-o', 0, 'normal');
INSERT INTO `fa_auth_rule` (`type`, `pid`, `name`, `title`, `icon`, `weigh`, `status`) VALUES ('file', (SELECT id FROM fa_auth_rule WHERE name = 'exam/application'), 'exam/application/downloadtemplate', '下载模板', 'fa fa-circle-o', 0, 'normal');
