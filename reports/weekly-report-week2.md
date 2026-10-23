# BÁO CÁO TIẾN ĐỘ TUẦN 2

## Đề tài: Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate

### 1. Thông tin đề tài

| Thông tin | Nội dung |
|---|---|
| Tên đề tài | Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate |
| Nền tảng triển khai | Amazon Web Services (AWS) |
| Dịch vụ sử dụng | Amazon ECS, AWS Fargate, Amazon ECR, Application Load Balancer (ALB), Amazon CloudWatch |
| Tuần báo cáo | Tuần 2 |
| Thành viên 1 | 24110208 |
| Thành viên 2 | 24110380 |

### 2. Phân công công việc và thời gian thực hiện

Trong Tuần 1 và Tuần 2, em (mã sinh viên 24110208) trực tiếp thực hiện các công việc của đề tài. Thành viên 24110380 đăng ký tham gia từ ngày 10/05 nhưng chưa trực tiếp thực hiện công việc trong hai tuần này. Vì vậy, em ghi nhận đúng tình hình tham gia thực tế của từng thành viên, không phân bổ kết quả hoặc số giờ chưa phát sinh cho thành viên còn lại.

| Mã sinh viên | Công việc thực hiện trong Tuần 2 | Kết quả | Thời gian |
|---|---|---|---|
| 24110208 | Kiểm tra hạ tầng AWS; hoàn thiện Task Definition; cập nhật ECS Service; kiểm thử ALB, Target Group, website và endpoint `/health`; kiểm tra CloudWatch Logs; thu thập và chuẩn bị minh chứng. | Đã cập nhật Task Definition lên Revision 2, triển khai thành công ECS Service và kiểm thử các thành phần chính. | Khoảng 1 giờ 30 phút cho phiên làm việc được ghi nhận hiện tại. |
| 24110380 | Chưa trực tiếp thực hiện công việc trong Tuần 2. | Chưa có kết quả thực hiện thực tế trong tuần báo cáo. | 0 giờ |

*Lưu ý: Thời gian 1 giờ 30 phút là số giờ em ước tính cho phiên làm việc hiện tại, không mặc nhiên đại diện cho tổng thời gian của toàn bộ Tuần 2. Tổng số giờ tuần cần được cập nhật theo nhật ký công việc thực tế nếu còn các phiên làm việc khác.*

### 3. Mục tiêu Tuần 2

Mục tiêu của Tuần 2 là triển khai và kiểm thử các chức năng cốt lõi trên AWS, bao gồm cấu hình ECS Cluster và Task Definition chạy bằng Fargate, triển khai Application Load Balancer, duy trì ECS Service chạy hai tasks và kiểm tra kết nối ứng dụng qua DNS của Load Balancer.

Do các tài nguyên cơ bản đã được tạo ở giai đoạn trước, em tập trung kiểm tra cấu hình hiện có, bổ sung phần Task role còn thiếu, triển khai revision mới và xác minh hệ thống sau khi cập nhật. Việc tái sử dụng các tài nguyên đã có giúp tránh tạo trùng tài nguyên AWS không cần thiết.

### 4. Nội dung công việc đã thực hiện

#### 4.1. Kiểm tra ECS Cluster và ECS Service

Em truy cập AWS Console để kiểm tra ECS Cluster `ecs-fargate-web-app-cluster` và ECS Service `ecs-fargate-web-app-service`. Em khởi chạy lại dịch vụ với số lượng mong muốn là hai tasks nhằm phục vụ kiểm thử.

Kết quả kiểm tra sau khi hoàn tất triển khai:

- ECS Service ở trạng thái `Active`.
- Desired tasks: 2.
- Running tasks: 2.
- Pending tasks: 0.
- Task Definition đang sử dụng: `ecs-fargate-web-app-task:2`.
- Deployment status: `Success`.

#### 4.2. Hoàn thiện Task Definition và cấu hình LabRole

Khi kiểm tra JSON của Task Definition Revision 1, em nhận thấy trường `executionRoleArn` đã trỏ đến `LabRole`, trong khi trường `taskRoleArn` chưa được khai báo.

Để đáp ứng yêu cầu của đề tài, em tạo Task Definition Revision 2 và cấu hình cả hai trường sử dụng cùng IAM role `LabRole`:

- Task role: `LabRole`.
- Task execution role: `LabRole`.

Em giữ nguyên các thông số cần thiết của ứng dụng, bao gồm môi trường AWS Fargate, hệ điều hành Linux/X86_64, chế độ mạng `awsvpc`, CPU 256 units, bộ nhớ 512 MiB, container port 5000 và cấu hình CloudWatch Logs.

Sau khi tạo Revision 2 thành công, em cập nhật ECS Service để sử dụng revision mới. AWS thực hiện rolling update bằng cách khởi chạy các tasks mới, sau đó loại bỏ các tasks cũ khi quá trình thay thế hoàn tất.

Kết quả cuối cùng cho thấy Revision 2 được triển khai thành công và ECS Service tiếp tục duy trì hai tasks đang chạy.

#### 4.3. Kiểm tra Application Load Balancer và Target Group

Em kiểm tra Application Load Balancer `ecs-fargate-web-app-alb`, có scheme `Internet-facing`, cùng Target Group `ecs-fargate-web-app-tg` sử dụng HTTP trên cổng 5000.

Trong quá trình cập nhật Revision 2, số lượng targets tăng tạm thời do AWS đăng ký các tasks mới trước khi loại bỏ các tasks cũ. Em tiếp tục theo dõi trạng thái Target Group cho đến khi quá trình triển khai ổn định.

Kết quả cuối cùng:

- Total targets: 2.
- Healthy: 2.
- Unhealthy: 0.
- Draining: 0.

Kết quả này xác nhận hai tasks mới đã được đăng ký vào Target Group và vượt qua health check.

#### 4.4. Kiểm thử kết nối ứng dụng qua ALB

Sau khi cập nhật ECS Service, em truy cập lại ứng dụng thông qua DNS của Application Load Balancer và kiểm tra endpoint `/health`.

Kết quả kiểm thử:

- Trang chủ ứng dụng truy cập được qua DNS của ALB.
- Endpoint `/health` trả về phản hồi thành công.
- Website tiếp tục hoạt động bình thường sau khi Service chuyển sang Task Definition Revision 2.

Kết quả cho thấy đường dẫn truy cập từ ALB đến các ECS tasks hoạt động sau khi hoàn tất triển khai.

#### 4.5. Kiểm tra CloudWatch Logs

Em truy cập log group `/ecs/ecs-fargate-web-app-task` để kiểm tra các log stream của ứng dụng.

Log ghi nhận Gunicorn khởi động, lắng nghe tại `0.0.0.0:5000`, khởi tạo worker và nhận các yêu cầu health check từ Load Balancer. Các yêu cầu `GET /health` được ghi nhận với mã phản hồi HTTP `200`.

Qua đó, em xác nhận ứng dụng có gửi log lên CloudWatch và có thể sử dụng log để theo dõi quá trình khởi động cũng như các yêu cầu kiểm tra sức khỏe của ứng dụng.

#### 4.6. Rà soát Security Group

Em kiểm tra Security Group `ecs-fargate-web-app-task-sg` và nhận thấy ALB cùng ECS tasks đang sử dụng chung Security Group này.

Hai quy tắc inbound được ghi nhận gồm:

- TCP cổng 5000, với Source là chính Security Group đang sử dụng.
- HTTP cổng 80, với Source là `0.0.0.0/0`.

Cấu hình hiện tại cho phép website hoạt động, tuy nhiên chưa tách riêng quyền truy cập giữa ALB và ECS tasks theo nguyên tắc bảo mật nên áp dụng. Trong phiên kiểm tra này, em mới rà soát và ghi nhận hiện trạng, chưa thay đổi quy tắc để tránh gây gián đoạn ứng dụng đang chạy.

Việc tách Security Group cho ALB và ECS tasks, đồng thời giới hạn nguồn truy cập cổng 5000, được ghi nhận là nội dung cần xem xét trong bước hoàn thiện bảo mật tiếp theo.

### 5. Kết quả kiểm thử

| Thành phần | Kết quả | Đánh giá |
|---|---|---|
| ECS Cluster | Tài nguyên hiện có được sử dụng để triển khai ứng dụng | Đạt |
| Task Definition | Revision 2 sử dụng `LabRole` cho cả Task role và Task execution role | Đạt |
| ECS Service | 2 Desired, 2 Running, 0 Pending; Deployment Success | Đạt |
| Application Load Balancer | Hoạt động và cung cấp DNS truy cập ứng dụng | Đạt |
| Target Group | 2 Healthy, 0 Unhealthy, 0 Draining | Đạt |
| Website | Truy cập được qua DNS của ALB sau triển khai | Đạt |
| Health endpoint | `/health` trả về phản hồi thành công | Đạt |
| CloudWatch Logs | Ghi nhận Gunicorn khởi động và health check HTTP 200 | Đạt |
| Security Group | Đã rà soát; phát hiện ALB và ECS tasks dùng chung nhóm bảo mật | Cần tiếp tục xem xét |

### 6. Danh mục minh chứng và liên kết trong repository

Em dự kiến lưu minh chứng trong thư mục `evidence/week2/` của repository. Sau khi ảnh được thêm và push lên GitHub, em sẽ bổ sung URL Blob thực tế vào cột cuối để giảng viên có thể mở trực tiếp từng file.

Mẫu URL Blob:

`https://github.com/<OWNER>/<REPOSITORY>/blob/<BRANCH>/evidence/week2/<TEN_FILE>.png`

Trong đó, em thay `<OWNER>`, `<REPOSITORY>`, `<BRANCH>` và `<TEN_FILE>` bằng thông tin thực tế của repository. Các vị trí bên dưới là chỗ để bổ sung URL thật, chưa phải liên kết đã xác minh.

| Tên file minh chứng | Nội dung | Link GitHub Blob |
|---|---|---|
| `01-ecs-service-2-tasks.png` | ECS Service và trạng thái hai tasks | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/01-ecs-service-2-tasks.png) |
| `05-cloudwatch-logs.png` | Danh sách log streams của ứng dụng | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/05-cloudwatch-logs.png) |
| `06-cloudwatch-log-events.png` | Log khởi động Gunicorn và các yêu cầu health check | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/06-cloudwatch-log-events.png) |
| `07-ecs-security-group-inbound.png` | Các quy tắc inbound của Security Group ECS tasks | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/07-ecs-security-group-inbound.png) |
| `07b-alb-security-group.png` | Security Group gắn với ALB | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/07b-alb-security-group.png) |
| `08-task-definition-roles.png` | JSON Revision 2 thể hiện cả hai trường role là `LabRole` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/08-task-definition-roles.png) |
| `09-task-definition-revision-2-created.png` | AWS xác nhận tạo Revision 2 thành công | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/09-task-definition-revision-2-created.png) |
| `10-service-update-revision-2.png` | Cấu hình cập nhật ECS Service sang Revision 2 | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/10-service-update-revision-2.png) |
| `11-service-revision-2-running.png` | Service chạy Revision 2 với hai tasks và Deployment Success | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/11-service-revision-2-running.png) |
| `12-target-group-health.png` | Target Group có hai targets Healthy | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/12-target-group-health.png) |
| `13-website-homepage.png` | Trang chủ truy cập qua DNS của ALB | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/13-website-homepage.png) |
| `14-health-endpoint.png` | Kết quả kiểm tra endpoint `/health` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week2/14-health-endpoint.png) |

**Ghi chú:** Em sẽ kiểm tra lại file thực tế trong repository và thay các dòng “Dán URL Blob tại đây” bằng URL GitHub Blob tương ứng. Em chỉ xác nhận một minh chứng đã được lưu khi file đã thực sự tồn tại trong repository.

### 7. Khó khăn và hướng xử lý tiếp theo

Trong quá trình kiểm tra, em phát hiện Task Definition Revision 1 chưa khai báo Task role. Em đã xử lý bằng cách tạo Revision 2, thiết lập `LabRole` cho cả Task role và Task execution role, sau đó cập nhật Service để sử dụng revision mới.

Trong quá trình rolling update, Target Group có thêm targets tạm thời và các targets cũ chuyển sang trạng thái `Draining`. Em tiếp tục theo dõi đến khi Target Group ổn định với hai targets Healthy.

Ngoài ra, việc ALB và ECS tasks dùng chung Security Group cho thấy cấu hình mạng vẫn cần được hoàn thiện. Các công việc tiếp theo gồm:

1. Hoàn tất kiểm tra các ảnh minh chứng trong `evidence/week2/` và bổ sung URL Blob vào báo cáo.
2. Xem xét tách Security Group cho ALB và ECS tasks để giới hạn nguồn truy cập phù hợp.
3. Kiểm thử lại website và endpoint `/health` nếu có thay đổi cấu hình mạng.
4. Cập nhật README và báo cáo tiến độ trong repository.
5. Commit các thay đổi thực tế để lịch sử Git phản ánh đúng tiến độ thực hiện.

### 8. Tổng kết của sinh viên

Trong Tuần 2, em đã kiểm tra và hoàn thiện một số cấu hình cốt lõi của ứng dụng web triển khai trên AWS. Em tạo Task Definition Revision 2 để đáp ứng yêu cầu sử dụng `LabRole` cho cả Task role và Task execution role, cập nhật ECS Service sang revision mới và xác nhận dịch vụ duy trì hai tasks đang chạy.

Sau khi triển khai, Target Group có hai targets Healthy, không còn targets Unhealthy hoặc Draining. Website và endpoint `/health` tiếp tục hoạt động bình thường. CloudWatch Logs ghi nhận quá trình khởi động của Gunicorn và các yêu cầu health check thành công.

Bên cạnh các kết quả đã đạt được, em đã ghi nhận vấn đề ALB và ECS tasks đang dùng chung Security Group để tiếp tục xem xét trong giai đoạn hoàn thiện bảo mật. Em sẽ tiếp tục hoàn thiện repository, bổ sung các liên kết Blob thực tế cho minh chứng và cập nhật báo cáo theo kết quả công việc thực hiện.

Trong Tuần 1 và Tuần 2, em (24110208) là người trực tiếp thực hiện công việc. Thành viên 24110380 chưa trực tiếp tham gia triển khai trong hai tuần này, vì vậy em không ghi nhận giờ làm hoặc kết quả chưa phát sinh của thành viên đó.