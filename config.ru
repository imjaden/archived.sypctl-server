# encoding: utf-8
require 'unicorn/oob_gc'
require 'unicorn/worker_killer'
require 'unicorn_metrics/middleware'
require './config/boot.rb'

# 每10次请求，才执行一次GC
use Unicorn::OobGC, 10
# Max requests per worker(1000 - 1500)
use Unicorn::WorkerKiller::MaxRequests, 1000, 1500
# Max memory size (RSS) per worker(256M - 1024M)
use Unicorn::WorkerKiller::Oom, (256*(1024**2)), (1024*(1024**2))

{
  '/' => 'ApplicationController',
  '/account' => 'Account::ApplicationController',
  '/account/app_groups' => 'Account::AppGroupController',
  '/account/apps' => 'Account::AppController',
  '/account/versions' => 'Account::VersionController',
  '/account/devices' => 'Account::DeviceController',
  '/account/device_groups' => 'Account::DeviceGroupController',
  '/account/jobs' => 'Account::JobController',
  '/account/job_templates' => 'Account::JobTemplateController',
  '/account/operation_logs' => 'Account::OperationLogController',
  '/api' => 'API::ApplicationController',
  '/api/v1' => 'API::V1Controller',
  '/api/v2' => 'API::V2Controller',
  '/api/v3' => 'API::V3Controller'
}.each_pair do |path, mod|
 map(path) { run mod.constantize }
end
