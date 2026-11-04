# BÁO CÁO TIẾN ĐỘ TUẦN 3

## Đề tài: Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate

### 1. Thông tin đề tài

| Thông tin            | Nội dung                                                        |
| -------------------- | --------------------------------------------------------------- |
| Tên đề tài           | Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate |
| Nhóm                 | Containers                                                      |
| Môn học              | Cloud - Dot 1 - 2026–2027                                       |
| Giảng viên hướng dẫn | Huỳnh Xuân Phụng                                                |
| Nền tảng triển khai  | Amazon Web Services (AWS)                                       |
| AWS Region           | `us-east-1` – US East (N. Virginia)                             |
| Thành viên 1         | 24110208 – Đỗ Lê Gia Hân                                        |
| Thành viên 2         | 24110380                                                        |

### 2. Phân công công việc và thời gian thực hiện

Trong tuần 1, em (mã sinh viên 24110208) trực tiếp thực hiện các công việc xây dựng ứng dụng, container hóa và triển khai những thành phần nền tảng trên AWS và tuần 2 em cũng thực hiện toàn bộ. Thành viên 24110380 đã đăng ký tham gia đề tài từ ngày 10/05 nhưng chưa trực tiếp tham gia triển khai trong các tuần trước.

Sang tuần 3, em tiếp tục thực hiện các công việc tích hợp, bảo mật, giám sát và quản lý tài nguyên AWS. Thành viên 24110380 chưa tham gia thực hiện công việc trong tuần này. Vì vậy, em ghi nhận đúng số giờ thực tế của từng thành viên như sau:

| Mã sinh viên | Thành viên    | Công việc trong tuần 3                                                                                                                                                           | Kết quả                                                                                 |       Số giờ |
| ------------ | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | -----------: |
| 24110208     | Đỗ Lê Gia Hân | Kiểm tra hoạt động ECS và ALB; kiểm tra CloudWatch Logs; cấu hình thời gian lưu log; tạo Dashboard và Alarm; rà soát và bổ sung tags cho tài nguyên AWS; scale ECS Service về 0. | Hoàn thành các nội dung tích hợp, bảo mật, giám sát và quản lý tài nguyên đã thực hiện. | Khoảng 4 giờ |
| 24110380     | Thành viên 2  | Chưa trực tiếp tham gia thực hiện công việc trong tuần 3.                                                                                                                        | Chưa có công việc, sản phẩm hoặc commit thực tế trong tuần.                             |        0 giờ |

**Tổng thời gian thực hiện trong tuần 3: khoảng 4 giờ.**

### 3. Mục tiêu tuần 3

Theo kế hoạch của đề tài, tuần 3 tập trung vào việc tích hợp các thành phần đã triển khai trên AWS, hoàn thiện cấu hình bảo mật và thiết lập hệ thống giám sát bằng Amazon CloudWatch.

Các nội dung em tập trung thực hiện gồm:

- Kiểm tra sự phối hợp giữa Application Load Balancer, Target Group và ECS Fargate.
- Rà soát Security Groups của ALB và ECS Tasks.
- Kiểm tra hoạt động của ứng dụng thông qua CloudWatch Logs.
- Thiết lập thời gian lưu trữ log phù hợp.
- Xây dựng CloudWatch Dashboard để theo dõi CPU, Memory và tình trạng ALB.
- Tạo CloudWatch Alarm theo dõi số lượng target không khỏe mạnh.
- Rà soát và bổ sung tags Project/Owner cho các tài nguyên AWS.
- Thực hiện scale ECS Service về 0 sau khi hoàn thành buổi thực hành để hạn chế chi phí.

### 4. Nội dung công việc đã thực hiện

#### 4.1. Kiểm tra hoạt động của ECS Service và Application Load Balancer

Em bắt đầu bằng việc truy cập Amazon ECS và kiểm tra Cluster `ecs-fargate-web-app-cluster`, sau đó mở Service `ecs-fargate-web-app-service` để xác nhận trạng thái triển khai hiện tại.

Tại thời điểm kiểm thử, Service sử dụng Task Definition Revision 2 và có cấu hình hai tasks mong muốn.

Thông tin kiểm tra:

| Thành phần                | Giá trị                       |
| ------------------------- | ----------------------------- |
| ECS Cluster               | `ecs-fargate-web-app-cluster` |
| ECS Service               | `ecs-fargate-web-app-service` |
| Task Definition           | `ecs-fargate-web-app-task:2`  |
| Application Load Balancer | `ecs-fargate-web-app-alb`     |
| Target Group              | `ecs-fargate-web-app-tg`      |
| Container port            | `5000`                        |

Trên trang ECS Service, hệ thống hiển thị:

| Thông số          | Kết quả |
| ----------------- | ------: |
| Desired tasks     |       2 |
| Running tasks     |       2 |
| Pending tasks     |       0 |
| Deployment status | Success |
| Healthy targets   |       2 |
| Unhealthy targets |       0 |

Em tiếp tục kiểm tra Target Group và xác nhận cả hai targets đều ở trạng thái Healthy. Điều này cho thấy các tasks đã được đăng ký và kiểm tra sức khỏe thành công thông qua Application Load Balancer.

Em cũng kiểm tra lại ứng dụng thông qua DNS của ALB và endpoint `/health`. Các request kiểm tra sức khỏe được xử lý thành công, với mã phản hồi HTTP 200 được ghi nhận trong CloudWatch Logs.

#### 4.2. Rà soát cấu hình bảo mật Security Groups

Sau khi kiểm tra hoạt động của Service, em tiếp tục rà soát các Security Groups được gắn với ALB và ECS Tasks.

Hai Security Groups được sử dụng:

| Thành phần                | Security Group ID      | Tên                           |
| ------------------------- | ---------------------- | ----------------------------- |
| Application Load Balancer | `sg-0691b478933950ad4` | `ecs-fargate-web-app-alb-sg`  |
| ECS Tasks                 | `sg-051591c7c511f7c37` | `ecs-fargate-web-app-task-sg` |

Security Group của ALB có mô tả `Allow HTTP traffic to ALB`, còn Security Group của ECS Tasks có mô tả `Allow traffic to Flask app on port 5000`.

Em kiểm tra lại các tài nguyên để xác nhận mỗi thành phần sử dụng Security Group tương ứng, đồng thời giữ nguyên cấu hình mạng đang hoạt động trong quá trình kiểm thử.

Việc tách biệt hai Security Groups giúp phân chia trách nhiệm kiểm soát lưu lượng giữa lớp tiếp nhận request từ bên ngoài và lớp chạy ứng dụng Flask.

#### 4.3. Kiểm tra CloudWatch Logs của hai ECS Tasks

Em truy cập Amazon CloudWatch, mở Log Group:

`/ecs/ecs-fargate-web-app-task`

Tại thời điểm kiểm tra, Log Group có 12 Log Streams. Hai Log Streams mới tương ứng với hai ECS Tasks được khởi chạy ngày 01/11/2026:

- `ecs/ecs-fargate-web-app/950f9a40ef794d6896192a44f1baa7e4`
- `ecs/ecs-fargate-web-app/45ce702aad124edd83f2f5a25ab0e33c`

Em lần lượt mở log của từng task để kiểm tra quá trình khởi động ứng dụng.

Cả hai log đều ghi nhận Gunicorn phiên bản 23.0.0 khởi động thành công, lắng nghe tại địa chỉ `0.0.0.0:5000` và khởi chạy hai worker.

Ví dụ log:

```text
Starting gunicorn 23.0.0
Listening at: http://0.0.0.0:5000
Using worker: sync
Booting worker with pid: 8
Booting worker with pid: 9
```

Các request health check từ Application Load Balancer cũng được ghi nhận thường xuyên:

```text
GET /health HTTP/1.1 200 21
ELB-HealthChecker/2.0
```

Ngoài ra, em kiểm tra log truy cập trang chủ và thấy request `GET /` trả về HTTP 200. Một số request `/favicon.ico` trả về HTTP 404, nhưng không ảnh hưởng đến hoạt động của trang chủ và endpoint `/health`.

Sau khi xác nhận log của cả hai tasks, em tiếp tục điều chỉnh thời gian lưu trữ log để phù hợp với việc quản lý tài nguyên.

#### 4.4. Thiết lập thời gian lưu trữ CloudWatch Logs

Trong phần Log group details, em kiểm tra thời gian lưu trữ hiện tại của Log Group `/ecs/ecs-fargate-web-app-task`.

Ban đầu, Retention được đặt là `Never expire`, tức là log không tự động hết hạn theo thời gian lưu trữ.

Em chọn Edit retention setting và thay đổi thành:

`1 month (30 days)`

Sau khi lưu, AWS hiển thị thông báo cập nhật thành công và phần Log group details hiển thị Retention là `1 month`.

Việc điều chỉnh này giúp log được lưu trong khoảng thời gian cần thiết để phục vụ kiểm tra, đồng thời tránh lưu trữ vô thời hạn các log không còn cần thiết.

#### 4.5. Theo dõi CPU và Memory bằng CloudWatch Metrics

Tiếp theo, em mở CloudWatch Metrics và chọn namespace `ECS`.

Tại nhóm dimension `ClusterName, ServiceName`, em tìm được hai metrics của đúng ECS Service:

- `CPUUtilization`
- `MemoryUtilization`

Cả hai metrics đều thuộc:

- Cluster: `ecs-fargate-web-app-cluster`
- Service: `ecs-fargate-web-app-service`

Trong quá trình cấu hình biểu đồ, em nhận thấy Statistic ban đầu đang được đặt là `Sum`. Cách thống kê này khiến các giá trị phần trăm bị cộng dồn trên biểu đồ.

Do đó, em mở Edit graph và thay đổi Statistic của cả hai metrics thành `Average`, giữ Period là `5 minutes`.

Cấu hình sau khi điều chỉnh:

| Metric            | Statistic | Period    |
| ----------------- | --------- | --------- |
| CPUUtilization    | Average   | 5 minutes |
| MemoryUtilization | Average   | 5 minutes |

Sau khi cập nhật, biểu đồ thể hiện mức sử dụng CPU và Memory theo giá trị trung bình thay vì cộng dồn các mẫu phần trăm.

#### 4.6. Theo dõi tình trạng ALB và Target Group

Ngoài CPU và Memory, em tiếp tục chọn namespace `ApplicationELB` trong CloudWatch Metrics để theo dõi tình trạng của Application Load Balancer và Target Group.

Các metrics được sử dụng:

| Metric             | Statistic | Period    |
| ------------------ | --------- | --------- |
| HealthyHostCount   | Minimum   | 5 minutes |
| UnHealthyHostCount | Maximum   | 5 minutes |
| RequestCount       | Sum       | 5 minutes |

Trong đó:

- `HealthyHostCount` theo dõi số lượng target khỏe mạnh.
- `UnHealthyHostCount` theo dõi số lượng target không khỏe mạnh.
- `RequestCount` theo dõi tổng số request được chuyển đến Target Group trong khoảng thời gian tương ứng.

Các metrics được chọn từ đúng ALB `ecs-fargate-web-app-alb` và Target Group `ecs-fargate-web-app-tg`.

Sau khi kiểm tra các chỉ số, em tạo CloudWatch Dashboard để tập trung theo dõi trạng thái của hệ thống.

#### 4.7. Tạo CloudWatch Dashboard

Em tạo Dashboard với tên:

`ECS-Fargate-Monitoring`

Dashboard gồm hai biểu đồ:

**Biểu đồ thứ nhất: ALB Target Group Health and Requests**

Theo dõi ba metrics:

- HealthyHostCount
- UnHealthyHostCount
- RequestCount

**Biểu đồ thứ hai: ECS CPU and Memory Utilization**

Theo dõi hai metrics:

- CPUUtilization
- MemoryUtilization

Đối với biểu đồ CPU và Memory, em chỉnh lại Statistic thành `Average` cho cả hai chỉ số trước khi cập nhật widget.

Sau khi thêm hai biểu đồ, em chọn Save dashboard để lưu lại các thay đổi.

Kết quả là Dashboard `ECS-Fargate-Monitoring` hiển thị đồng thời thông tin giám sát của ECS Service và Application Load Balancer, giúp em thuận tiện theo dõi hoạt động của ứng dụng trên cùng một giao diện.

#### 4.8. Tạo CloudWatch Alarm giám sát UnHealthyHostCount

Sau khi hoàn thành Dashboard, em tiếp tục tạo CloudWatch Alarm để theo dõi tình trạng không khỏe mạnh của Target Group.

Alarm được đặt tên:

`ECS-Fargate-UnHealthyHost-Alarm`

Thông tin cấu hình:

| Thuộc tính             | Giá trị                       |
| ---------------------- | ----------------------------- |
| Namespace              | `AWS/ApplicationELB`          |
| Metric                 | `UnHealthyHostCount`          |
| Target Group           | `ecs-fargate-web-app-tg`      |
| Load Balancer          | `ecs-fargate-web-app-alb`     |
| Statistic              | Minimum                       |
| Period                 | 5 minutes                     |
| Threshold type         | Static                        |
| Điều kiện              | Greater than 0                |
| Datapoints to alarm    | 2 out of 2                    |
| Missing data treatment | Treat missing data as missing |

Alarm được cấu hình để chuyển sang trạng thái ALARM khi giá trị `UnHealthyHostCount` lớn hơn 0 trong hai datapoint đánh giá liên tiếp.

Em không cấu hình SNS hoặc email notification trong phạm vi thực hiện tuần này. Trạng thái Alarm được theo dõi trực tiếp trên CloudWatch Console.

Sau khi tạo thành công, Alarm ban đầu hiển thị `Insufficient data`. Sau khi CloudWatch thu thập và đánh giá dữ liệu, Alarm chuyển sang trạng thái `OK`.

Tại thời điểm kiểm tra ngày 01/11/2026, AWS hiển thị:

`ECS-Fargate-UnHealthyHost-Alarm – OK`

#### 4.9. Rà soát và bổ sung Tags cho các tài nguyên AWS

Theo yêu cầu chung của đề tài, em tiếp tục kiểm tra tags của các tài nguyên đã triển khai.

Hai tags được sử dụng thống nhất:

| Key     | Value              |
| ------- | ------------------ |
| Project | `ECSFargateWebApp` |
| Owner   | `Do Le Gia Han`    |

Qua quá trình rà soát, em bổ sung tags cho các tài nguyên sau:

| STT | Tài nguyên                 | Trạng thái   |
| --- | -------------------------- | ------------ |
| 1   | ECS Task Security Group    | Đã bổ sung   |
| 2   | ALB Security Group         | Đã có đầy đủ |
| 3   | Application Load Balancer  | Đã bổ sung   |
| 4   | Target Group               | Đã bổ sung   |
| 5   | ECS Cluster                | Đã bổ sung   |
| 6   | ECS Service                | Đã bổ sung   |
| 7   | Task Definition Revision 2 | Đã bổ sung   |
| 8   | ECR Repository             | Đã bổ sung   |
| 9   | CloudWatch Log Group       | Đã bổ sung   |
| 10  | CloudWatch Alarm           | Đã có đầy đủ |

Đối với các tài nguyên đã có tags do CloudFormation tạo tự động, em giữ nguyên tags hệ thống và bổ sung thêm hai tags của đề tài.

#### 4.10. Scale ECS Service về 0 sau buổi thực hành

Sau khi hoàn thành quá trình kiểm thử, giám sát và rà soát tài nguyên, em tiến hành cập nhật ECS Service thông qua AWS Console.

Tại phần Update service, em thay đổi Desired tasks từ 2 xuống 0, giữ nguyên Task Definition Revision 2 và các cấu hình còn lại.

Sau khi AWS cập nhật thành công, trang Service hiển thị:

| Thông số          | Kết quả                      |
| ----------------- | ---------------------------- |
| ECS Service       | Active                       |
| Desired tasks     | 0                            |
| Running tasks     | 0                            |
| Pending tasks     | 0                            |
| Task Definition   | `ecs-fargate-web-app-task:2` |
| Deployment status | Success                      |

Trong phần Events, AWS ghi nhận hai tasks đã được dừng và hai targets được deregister khỏi Target Group.

### 5. Tổng hợp kết quả thực hiện tuần 3

| STT | Hạng mục                    | Kết quả                                      |
| --- | --------------------------- | -------------------------------------------- |
| 1   | Kiểm tra ECS Service và ALB | Hai tasks hoạt động, hai targets Healthy     |
| 2   | Rà soát Security Groups     | Có Security Group riêng cho ALB và ECS Tasks |
| 3   | CloudWatch Logs             | Kiểm tra log của cả hai tasks                |
| 4   | Log Retention               | Đã chuyển sang 30 ngày                       |
| 5   | CloudWatch Metrics          | Theo dõi CPU, Memory và ALB                  |
| 6   | CloudWatch Dashboard        | Đã tạo và lưu `ECS-Fargate-Monitoring`       |
| 7   | CloudWatch Alarm            | Đã tạo, trạng thái OK                        |
| 8   | Resource Tags               | Đã rà soát và bổ sung Project/Owner          |
| 9   | Scale ECS Service           | Desired 0, Running 0, Pending 0              |

Các thao tác triển khai, kiểm thử và giám sát được thực hiện trên AWS Learner Lab tại Region `us-east-1`.

### 6. Minh chứng thực hiện tuần 3

Các ảnh chụp AWS Console và kết quả kiểm thử được lưu trong repository tại thư mục `evidence/week3/`. Link blob trực tiếp cho từng minh chứng được ghi trong bảng dưới để giảng viên có thể mở và đối chiếu.

| STT | Tên file minh chứng                              | Nội dung                                                 | Link Blob                |
| --- | ------------------------------------------------ | -------------------------------------------------------- | ------------------------ |
| 09  | `09-cloudwatch-new-task-log-streams.png`         | Danh sách CloudWatch Log Streams của hai tasks mới       | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/09-cloudwatch-new-task-log-streams.png) |
| 10  | `10-cloudwatch-task-log-events.png`              | Log khởi động Gunicorn và health check của Task thứ nhất | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/10-cloudwatch-task-log-events.png) |
| 11  | `11-cloudwatch-second-task-log-events.png`       | Log hoạt động của Task thứ hai                           | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/11-cloudwatch-second-task-log-events.png) |
| 12  | `12-cloudwatch-log-retention-30-days.png`        | Log Group có Retention 30 ngày                           | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/12-cloudwatch-log-retention-30-days.png) |
| 13  | `13-ecs-service-health-2-healthy.png`            | ECS Service có hai tasks và hai targets Healthy          | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/13-ecs-service-health-2-healthy.png) |
| 14  | `14-cloudwatch-ecs-cpu-memory-metrics.png`       | CloudWatch Metrics CPU và Memory                         | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/14-cloudwatch-ecs-cpu-memory-metrics.png) |
| 15  | `15-cloudwatch-ecs-alb-health-metrics.png`       | Metrics HealthyHostCount và UnHealthyHostCount           | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/15-cloudwatch-ecs-alb-health-metrics.png) |
| 16  | `16-cloudwatch-dashboard-alb-monitoring.png`     | Widget giám sát ALB trên Dashboard                       | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/16-cloudwatch-dashboard-alb-monitoring.png) |
| 17  | `17-cloudwatch-ecs-cpu-memory-metrics.png`       | Widget CPU và Memory sau khi chỉnh Average               | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/17-cloudwatch-ecs-cpu-memory-metrics.png) |
| 18  | `18-cloudwatch-dashboard-full-monitoring.png`    | Dashboard đầy đủ hai biểu đồ                             | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/18-cloudwatch-dashboard-full-monitoring.png) |
| 19  | `19-cloudwatch-alarm-state-ok.png`               | CloudWatch Alarm có trạng thái OK                        | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/19-cloudwatch-alarm-state-ok.png) |
| 20  | `20-task-sg-tags-project-owner.png`              | Tags của ECS Task Security Group                         | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/20-task-sg-tags-project-owner.png) |
| 21  | `21-alb-sg-tags-project-owner.png`               | Tags của ALB Security Group                              | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/21-alb-sg-tags-project-owner.png) |
| 22  | `22-alb-tags-project-owner.png`                  | Tags của Application Load Balancer                       | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/22-alb-tags-project-owner.png) |
| 23  | `23-target-group-tags-project-owner.png`         | Tags của Target Group                                    | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/23-target-group-tags-project-owner.png) |
| 24  | `24-ecs-cluster-tags-project-owner.png`          | Tags của ECS Cluster                                     | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/24-ecs-cluster-tags-project-owner.png) |
| 25  | `25-ecs-service-tags-project-owner.png`          | Tags của ECS Service                                     | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/25-ecs-service-tags-project-owner.png) |
| 26  | `26-task-definition-tags-project-owner.png`      | Tags của Task Definition Revision 2                      | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/26-task-definition-tags-project-owner.png) |
| 27  | `27-ecr-repository-tags-project-owner.png`       | Tags của ECR Repository                                  | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/27-ecr-repository-tags-project-owner.png) |
| 28  | `28-cloudwatch-log-group-tags-project-owner.png` | Tags của CloudWatch Log Group                            | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/28-cloudwatch-log-group-tags-project-owner.png) |
| 29  | `29-cloudwatch-alarm-tags-project-owner.png`     | Tags của CloudWatch Alarm                                | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/29-cloudwatch-alarm-tags-project-owner.png) |
| 30  | `30-ecs-service-scaled-to-zero.png`              | ECS Service đã scale về 0                                | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week3/30-ecs-service-scaled-to-zero.png) |

### 7. Repository GitHub và các liên kết mã nguồn

#### 7.1. Thông tin repository

| Thông tin                 | Nội dung                                                                   |
| ------------------------- | -------------------------------------------------------------------------- |
| Repository                | [ecs-fargate-web-app](https://github.com/24110208-rgb/ecs-fargate-web-app) |
| Chủ sở hữu repository     | `24110208-rgb`                                                             |
| Branch                    | `main`                                                                     |
| Thư mục báo cáo           | `reports/`                                                                 |
| Thư mục minh chứng tuần 3 | `evidence/week3/`                                                          |

#### 7.2. Các liên kết GitHub Blob đến file thực tế 

Các file mã nguồn chính được liên kết trực tiếp đến từng file trong repository để giảng viên có thể mở và kiểm tra:

| STT | File                       | GitHub Blob                                                                                             |
| --- | -------------------------- | ------------------------------------------------------------------------------------------------------- |
| 1   | `app/app.py`               | [Mở app.py](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/app/app.py)                   |
| 2   | `Dockerfile`               | [Mở Dockerfile](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/Dockerfile)               |
| 3   | `requirements.txt`         | [Mở requirements.txt](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/requirements.txt)   |
| 4   | `README.md`                | [Mở README.md](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/README.md)                 |
| 5   | `app/templates/index.html` | [Mở index.html](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/app/templates/index.html) |

#### 7.3. Báo cáo và minh chứng tuần 3 trên GitHub

Các file cần được cập nhật trong repository:

- Báo cáo tuần 3: `reports/weekly-report-week3.md`
- Ảnh minh chứng: `evidence/week3/`

Cấu trúc repository hiện tại:

```text
ecs-fargate-web-app/
├── app/
│   ├── templates/
│   │   └── index.html
│   └── app.py
├── evidence/
│   ├── week1/
│   ├── week2/
│   └── week3/
│       ├── 09-cloudwatch-new-task-log-streams.png
│       ├── 10-cloudwatch-task-log-events.png
│       ├── 11-cloudwatch-second-task-log-events.png
│       ├── ...
│       └── 30-ecs-service-scaled-to-zero.png
├── reports/
│   ├── weekly-report-week1.md
│   ├── weekly-report-week2.md
│   └── weekly-report-week3.md
├── .dockerignore
├── .gitignore
├── Dockerfile
├── README.md
└── requirements.txt
```

#### 7.4. Commit và lịch sử công việc 

Các commit đã có từ những tuần trước được giữ nguyên để đối chiếu:

| Commit | Nội dung                                            | Liên kết                                                                                                                                        |
| ------ | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Tuần 1 | `Build Flask web app with optimized Docker image`   | [7b46a550590707dfc2a15edca25f0fc7bdd754e7](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/7b46a550590707dfc2a15edca25f0fc7bdd754e7) |
| Tuần 2 | `Add week2 evidence screenshots and weekly report`  | [17952794ca8b921c646e620a30c73208d9a4e9f9](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/17952794ca8b921c646e620a30c73208d9a4e9f9) |
| Tuần 2 | `docs: add blob links for week2 evidence in report` | [f4bef2bb99d54a1191f009780c3c8fdea20c5a08](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/f4bef2bb99d54a1191f009780c3c8fdea20c5a08) |
| Tuần 2 | `docs: update week2 report`                         | [8314a495fda602ba234b51253f6ea0f06a4bd960](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/8314a495fda602ba234b51253f6ea0f06a4bd960) |

**Commit tuần 3:**

| Commit | Nội dung | Liên kết |
| ------ | -------- | -------- |
| Tuần 3 | `Add week3 evidence screenshots` | [8b66336](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/8b66336cff491e74b03b33d7673d1528ed971641) |

*Commit tuần 3 chứa 29 ảnh minh chứng trong thư mục `evidence/week3/`. Thành viên 24110380 chưa có commit tuần 3 vì chưa trực tiếp tham gia thực hiện công việc.*

### 8. Khó khăn và nội dung cần tiếp tục

Trong tuần 3, em đã thực hiện nhiều bước kiểm tra và cấu hình bổ sung trên AWS Console. Quá trình theo dõi CloudWatch giúp em hiểu rõ hơn cách sử dụng các metrics để quan sát tài nguyên ECS, tình trạng ALB và cách tạo cảnh báo khi Target Group có vấn đề.

Một vấn đề em gặp trong quá trình giám sát là biểu đồ CPU và Memory ban đầu sử dụng Statistic `Sum`, dẫn đến giá trị phần trăm bị cộng dồn. Sau khi kiểm tra, em đổi sang `Average` cho hai metrics và cập nhật lại Dashboard.

Ngoài ra, khi mới tạo CloudWatch Alarm, trạng thái ban đầu là `Insufficient data`. Sau khi CloudWatch có đủ dữ liệu đánh giá, Alarm chuyển sang `OK`.

### 9. Tổng kết

Trong tuần 3, em đã tập trung kiểm tra hoạt động của hệ thống sau khi tích hợp các thành phần AWS, bổ sung cấu hình giám sát và rà soát việc quản lý tài nguyên.

Qua quá trình thực hiện, em có thêm kinh nghiệm trong việc đọc CloudWatch Logs, lựa chọn metrics phù hợp, xây dựng Dashboard và thiết lập Alarm để theo dõi trạng thái của hệ thống. Em cũng rà soát tags Project/Owner cho các tài nguyên và thực hiện scale ECS Service về 0 sau buổi thực hành.

Kết thúc tuần 3, các tài nguyên và cấu hình chính vẫn được giữ lại trên AWS, trong khi hai Fargate Tasks đã được dừng để hạn chế chi phí. Tuần 4 em sẽ tập trung kiểm thử tổng thể, tối ưu chi phí, hoàn thiện tài liệu và chuẩn bị demo sản phẩm.

**Sinh viên thực hiện báo cáo:**

Đỗ Lê Gia Hân

**Mã số sinh viên:** 24110208

**Thời gian cập nhật:** 01/11/2026