# BÁO CÁO TIẾN ĐỘ TUẦN 2

## Đề tài: Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate

### 1. Thông tin đề tài

| Thông tin | Nội dung |
|---|---|
| Tên đề tài | Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate |
| Nền tảng triển khai | Amazon Web Services (AWS) |
| AWS Region | `us-east-1` – US East (N. Virginia) |
| Dịch vụ sử dụng | Amazon ECS, AWS Fargate, Amazon ECR, Application Load Balancer (ALB), Amazon CloudWatch |
| Tuần báo cáo | Tuần 2 |
| Thành viên 1 | 24110208_Đỗ Lê Gia Hân |
| Thành viên 2 | 24110380 |

### 2. Phân công công việc và thời gian thực hiện

Trong Tuần 1 và Tuần 2, em (mã sinh viên 24110208) trực tiếp thực hiện công việc của đề tài. Thành viên 24110380 đăng ký tham gia từ ngày 10/05 nhưng chưa trực tiếp tham gia triển khai trong hai tuần này. Vì vậy, em ghi nhận tình hình phân công theo đúng công việc thực tế, không ghi thêm kết quả hoặc số giờ cho thành viên chưa thực hiện.

| Mã sinh viên | Công việc trong Tuần 2 | Kết quả | Thời gian |
|---|---|---|---|
| 24110208 | Kiểm tra cấu hình AWS hiện có; kiểm tra Task Definition; tạo Revision 2; cập nhật ECS Service; theo dõi rolling update; kiểm tra Target Group, website, endpoint `/health`, CloudWatch Logs và Security Group. | Đã cập nhật Service sang Revision 2, xác nhận hai tasks hoạt động và kiểm thử các thành phần chính. | Khoảng 1 giờ 30 phút cho phiên làm việc được ghi nhận. |
| 24110380 | Chưa trực tiếp thực hiện công việc trong Tuần 2. | Chưa có kết quả công việc thực tế trong tuần báo cáo. | 0 giờ |

*Lưu ý: Số giờ 1 giờ 30 phút là thời lượng em ghi nhận cho phiên làm việc này, không tự động đại diện cho tổng thời gian của toàn bộ Tuần 2. Nếu có những phiên làm việc khác trong tuần, em sẽ cộng theo nhật ký thực tế trước khi nộp.*

### 3. Mục tiêu Tuần 2

Trong Tuần 2, em tiếp tục kiểm tra và hoàn thiện các thành phần cốt lõi của hệ thống đã triển khai ở giai đoạn trước. Các nội dung cần thực hiện gồm kiểm tra cấu hình ECS Cluster và Task Definition chạy trên Fargate, bảo đảm `LabRole` được cấu hình cho cả Task role và Task execution role, duy trì ECS Service chạy 2 tasks, đồng thời kiểm tra kết nối từ Application Load Balancer đến các tasks thông qua Target Group.

Do Cluster, ALB, Target Group và ECS Service đã tồn tại từ trước, em sử dụng lại các tài nguyên này thay vì tạo mới toàn bộ hệ thống. Cách làm này giúp em tập trung vào phần cấu hình còn thiếu, triển khai revision mới và kiểm tra hoạt động thực tế sau khi cập nhật.

### 4. Nội dung công việc đã thực hiện

#### 4.1. Kiểm tra hạ tầng ECS hiện có

Em mở AWS Console, vào Amazon Elastic Container Service và chọn Cluster `ecs-fargate-web-app-cluster`. Tại ECS Service `ecs-fargate-web-app-service`, em kiểm tra trạng thái dịch vụ, Task Definition đang sử dụng và số lượng tasks.

Trước khi cập nhật cấu hình, Service đang sử dụng `ecs-fargate-web-app-task:1`. Ở lần khởi chạy lại phục vụ kiểm thử, em đặt Desired tasks thành `2` và chờ cho đến khi Service hiển thị `2 running`, `0 pending`.

Sau đó, em kiểm tra Target Group để xác nhận hai tasks đã đăng ký và chuyển sang trạng thái Healthy. Khi các thành phần hoạt động, em tiếp tục kiểm tra Task Definition để đối chiếu cấu hình IAM role với yêu cầu của đề tài.

#### 4.2. Phát hiện Task Definition Revision 1 thiếu Task role

Em vào **ECS → Task definitions → `ecs-fargate-web-app-task` → Revision 1**, sau đó mở tab **JSON** để kiểm tra cấu hình thực tế thay vì chỉ dựa vào thông tin tổng quan trên giao diện.

Trong JSON của Revision 1, em tìm thấy trường:

`"executionRoleArn": "arn:aws:iam::729012882197:role/LabRole"`

Tuy nhiên, em không tìm thấy trường `taskRoleArn`. Như vậy, Revision 1 đã cấu hình `LabRole` cho Task execution role nhưng chưa khai báo Task role theo yêu cầu của đề tài.

Ở bước này, em không thấy một thông báo lỗi cụ thể từ AWS Console; vấn đề được phát hiện bằng cách tự đối chiếu JSON của Task Definition với yêu cầu cấu hình. Em kiểm tra lại các trường liên quan, xác nhận `executionRoleArn` đang trỏ đến `LabRole`, đồng thời xác định `taskRoleArn` chưa xuất hiện trong JSON.

Sau khi xác định phần cần bổ sung, em quyết định tạo revision mới thay vì sửa trực tiếp Revision 1. Cách làm này giữ lại cấu hình cũ để đối chiếu và cho phép ECS Service được cập nhật sang phiên bản Task Definition mới.

#### 4.3. Tạo Task Definition Revision 2

Tại trang Task Definition, em chọn **Actions → Create new revision**, sau đó kiểm tra biểu mẫu cấu hình mới.

Ở phần **Task roles**, em thay Task role từ `None` thành `LabRole`. Trường Task execution role vốn đã là `LabRole`, nên em giữ nguyên. Sau khi chọn xong, cả hai trường đều sử dụng cùng role.

Các thông số còn lại được giữ theo cấu hình đang chạy:

| Thông số | Giá trị |
|---|---|
| Task definition family | `ecs-fargate-web-app-task` |
| Revision mới | `2` |
| Launch type | AWS Fargate |
| Operating system/Architecture | Linux/X86_64 |
| Network mode | `awsvpc` |
| CPU | 256 units – 0,25 vCPU |
| Memory | 512 MiB – 0,5 GiB |
| Container name | `ecs-fargate-web-app` |
| Container image | `729012882197.dkr.ecr.us-east-1.amazonaws.com/ecs-fargate-web-app:week1` |
| Container port | `5000/TCP` |
| App protocol | HTTP |
| CloudWatch log group | `/ecs/ecs-fargate-web-app-task` |
| Log stream prefix | `ecs` |

Sau khi kiểm tra các thông số, em nhấn **Create**. AWS thông báo tạo thành công `ecs-fargate-web-app-task:2` và revision mới xuất hiện ở trạng thái `Active`.

Em mở JSON của Revision 2 để xác minh lại hai trường:

- `taskRoleArn`: `arn:aws:iam::729012882197:role/LabRole`
- `executionRoleArn`: `arn:aws:iam::729012882197:role/LabRole`

Đến bước này, em đã xác nhận cấu hình Task Definition Revision 2 đáp ứng yêu cầu về hai IAM roles.

#### 4.4. Cập nhật ECS Service sang Revision 2

Sau khi tạo Revision 2, em quay lại `ecs-fargate-web-app-cluster`, mở Service `ecs-fargate-web-app-service` và chọn **Update service**.

Trong biểu mẫu cập nhật, em chọn Task Definition family `ecs-fargate-web-app-task`, thay revision đang chọn từ `1` thành `2`, giữ Scheduling strategy là `REPLICA` và Desired tasks là `2`. Em không thay đổi các cấu hình mạng và Load balancing đang sử dụng.

Sau khi nhấn Update, AWS hiển thị thông báo `Deployment in progress`. Theo thông tin Deployment timeline trên trang Service:

- Deployment bắt đầu lúc **19:38, ngày 23/10/2026 (UTC+7)**.
- Deployment hoàn tất lúc **19:41, ngày 23/10/2026 (UTC+7)**.
- Thời gian triển khai được AWS ghi nhận là **2 phút 59 giây**.

Trong quá trình cập nhật, em thấy Service tạm thời hiển thị `2 Desired`, `3 running`, `0 pending`. Khi mở phần Deployments, em thấy revision đích `ecs-fargate-web-app-task:2` có `2 Requested`, `2 Running`, `0 Pending`, trong khi revision nguồn `ecs-fargate-web-app-task:1` còn `1 Running`.

Em tiếp tục theo dõi các sự kiện của Service. AWS ghi nhận tasks mới được khởi chạy và đăng ký vào Target Group trước khi tasks thuộc revision cũ được rút khỏi hệ thống. Sau đó, các sự kiện `begun draining connections`, `deregistered targets` và `stopped running tasks` lần lượt xuất hiện. Em không dừng các tasks thủ công và không bấm Update lặp lại trong lúc deployment đang diễn ra.

Khi tải lại trang Service sau khi triển khai hoàn tất, giao diện hiển thị:

- Task Definition: `ecs-fargate-web-app-task:2`
- Desired tasks: `2`
- Running tasks: `2`
- Pending tasks: `0`
- Deployment status: `Success`

#### 4.5. Theo dõi Target Group trong rolling update

Sau khi bắt đầu cập nhật ECS Service lúc 19:38 ngày 23/10/2026 (UTC+7), em tiếp tục kiểm tra Target Group bằng cách tải lại trang Targets trên AWS Console. Theo Deployment timeline, quá trình triển khai được ghi nhận hoàn tất lúc 19:41, với thời lượng 2 phút 59 giây. Trong lần kiểm tra Target Group đầu tiên, giao diện hiển thị 4 targets, gồm 2 Healthy và 2 Draining. Ở lần kiểm tra tiếp theo, tổng số targets giảm xuống 3, gồm 2 Healthy và 1 Draining. Target còn lại có IP `172.31.68.210`, cổng 5000, thuộc Availability Zone `us-east-1f`.

Em tiếp tục tải lại trang và thấy Target Group ổn định ở 2 targets Healthy, không còn targets Draining:

| IP address | Port | Availability Zone | Health status |
|---|---:|---|---|
| `172.31.95.79` | 5000 | `us-east-1c` | Healthy |
| `172.31.48.82` | 5000 | `us-east-1e` | Healthy |

Theo Deployment timeline, toàn bộ đợt rolling update hoàn tất trong 2 phút 59 giây. Do các lần kiểm tra Target Group không có mốc thời gian riêng được ghi lại cho từng ảnh, em chỉ xác định được chuỗi thay đổi trạng thái trong khoảng triển khai nói trên, không khẳng định chính xác mỗi trạng thái 4 hoặc 3 targets kéo dài bao lâu.

#### 4.6. Kiểm thử website và endpoint `/health`

Sau khi Target Group ổn định, em mở trình duyệt và truy cập website qua DNS của ALB:

`http://ecs-fargate-web-app-alb-577919456.us-east-1.elb.amazonaws.com/`

Em kiểm tra trang chủ và xác nhận ứng dụng vẫn truy cập được sau khi ECS Service chuyển sang Revision 2. Tiếp theo, em mở endpoint kiểm tra sức khỏe:

`http://ecs-fargate-web-app-alb-577919456.us-east-1.elb.amazonaws.com/health`

Endpoint trả về phản hồi thành công. Sau khi kiểm tra, em lưu ảnh màn hình trang chủ và endpoint `/health` làm minh chứng cho việc truy cập ứng dụng thông qua DNS của ALB sau khi cập nhật Task Definition Revision 2.

#### 4.7. Kiểm tra CloudWatch Logs

Em mở CloudWatch, vào log group `/ecs/ecs-fargate-web-app-task` và kiểm tra danh sách log streams. Tại thời điểm kiểm tra, giao diện hiển thị **8 log streams**. Hai stream gần đây nhất có tên:

- `ecs/ecs-fargate-web-app/17cb272453474e66970089c032e405b0`
- `ecs/ecs-fargate-web-app/1a489a2b8e2e44b0a8cbecd64a7d8a51`

Các log này tương ứng với hai tasks đang chạy trước đợt cập nhật Revision 2, không phải hai tasks mới được tạo trong rolling update. Em mở một stream để kiểm tra nội dung và thấy Gunicorn phiên bản `23.0.0` khởi động, lắng nghe tại `http://0.0.0.0:5000` và khởi tạo các worker. Các yêu cầu `GET /health` từ `ELB-HealthChecker/2.0` được ghi nhận với mã HTTP `200` và độ dài phản hồi `21` bytes.

Em cũng thấy yêu cầu `GET /favicon.ico` trả về HTTP `404`. Đây là yêu cầu lấy biểu tượng trang web, khác với endpoint health check. Do trang chủ vẫn truy cập được và các yêu cầu `/health` vẫn trả về thành công, em ghi nhận hiện tượng này nhưng không thay đổi ứng dụng chỉ để xử lý favicon trong phiên kiểm thử.

Sau khi cập nhật Revision 2, em kiểm tra trạng thái ECS Service và Target Group để xác nhận hai tasks mới hoạt động bình thường. Các log đã đọc chứng minh ứng dụng có ghi log và health check hoạt động ở giai đoạn trước cập nhật; em không dùng chúng để khẳng định log của hai tasks mới sau khi chuyển revision.

#### 4.8. Rà soát Security Group

Sau khi xác minh ứng dụng hoạt động, em kiểm tra **EC2 → Security Groups** và chọn Security Group `ecs-fargate-web-app-task-sg`, ID `sg-051591c7c511f7c37`.

Trong phần Inbound rules, em thấy hai quy tắc:

| Type | Protocol | Port range | Source |
|---|---|---:|---|
| Custom TCP | TCP | 5000 | `sg-051591c7c511f7c37` |
| HTTP | TCP | 80 | `0.0.0.0/0` |

Em tiếp tục mở Load Balancer `ecs-fargate-web-app-alb`. Trong phần Security groups, ALB cũng được gắn với `sg-051591c7c511f7c37`, cùng Security Group mà ECS tasks đang sử dụng.

Từ thông tin này, em xác định cấu hình hiện tại chưa tách Security Group riêng cho ALB và ECS tasks. Em mới kiểm tra, chụp minh chứng và ghi nhận vấn đề; em không thay đổi quy tắc inbound trong phiên này để tránh làm gián đoạn hệ thống đang chạy. Việc tách Security Group và giới hạn nguồn được phép truy cập cổng 5000 sẽ được xem xét trong bước hoàn thiện bảo mật tiếp theo.

#### 4.9. Trạng thái cuối phiên làm việc

Sau khi hoàn tất các bước kiểm thử và thu thập minh chứng, em cập nhật ECS Service, đưa Desired tasks từ 2 về 0 lúc khoảng 20:38 ngày 23/10/2026 (UTC+7) để hạn chế chi phí Fargate khi tạm ngừng sử dụng. AWS Console sau đó hiển thị 0 Desired, 0 running, 0 pending và Deployment status Success. Em giữ lại ECS Service, Cluster, Task Definition, ALB và Target Group để tiếp tục sử dụng khi triển khai lại ở tuần sau.

### 5. Tổng hợp kết quả kiểm thử

| Thành phần | Kết quả thực tế | Đánh giá |
|---|---|---|
| ECS Cluster | Sử dụng `ecs-fargate-web-app-cluster` hiện có | Đã kiểm tra |
| Task Definition | Revision 2 có `LabRole` ở cả `taskRoleArn` và `executionRoleArn` | Đạt |
| ECS Service | Revision 2; 2 Desired, 2 Running, 0 Pending | Đạt |
| Deployment | Bắt đầu 19:38, hoàn tất 19:41 ngày 23/10/2026; thời lượng 2 phút 59 giây | Success |
| Application Load Balancer | `ecs-fargate-web-app-alb`, scheme `Internet-facing` | Hoạt động |
| Target Group | 2 Healthy, 0 Unhealthy, 0 Initial, 0 Draining sau deployment | Đạt |
| Website | Truy cập qua DNS của ALB | Thành công |
| Health endpoint | `/health` trả về phản hồi thành công; log ghi nhận HTTP 200 | Đạt |
| CloudWatch Logs | Log group `/ecs/ecs-fargate-web-app-task`; 8 log streams; ghi nhận Gunicorn và health check | Đã kiểm tra |
| Security Group | ALB và ECS tasks đang dùng chung `sg-051591c7c511f7c37` | Cần xem xét hoàn thiện |

### 6. Danh mục minh chứng và liên kết trong repository

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


### 7. Lịch sử commit và liên kết repository

**File báo cáo trong repository:** [reports/weekly-report-week2.md](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/reports/weekly-report-week2.md)

Các commit liên quan đến Tuần 2 trên nhánh `main`:

| Commit | Ngày | Nội dung |
|---|---|---|
| [`1795279`](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/17952794ca8b921c646e620a30c73208d9a4e9f9) | 23/10/2026 | Add week2 evidence screenshots and weekly report |
| [`f4bef2b`](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/f4bef2bb99d54a1191f009780c3c8fdea20c5a08) | 23/10/2026 | docs: add blob links for week2 evidence in report |
| [`8314a49`](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/8314a495fda602ba234b51253f6ea0f06a4bd960) | 23/10/2026 | docs: update week2 report |

### 8. Khó khăn và công việc cần tiếp tục

Trong quá trình kiểm tra, em phát hiện Revision 1 chưa có trường `taskRoleArn`. Em đối chiếu JSON, tạo Revision 2, cấu hình `LabRole` cho cả Task role và Task execution role, sau đó cập nhật ECS Service để sử dụng revision mới.

Trong quá trình rolling update, Target Group tăng tạm thời lên 4 targets, sau đó giảm còn 3 targets với một target Draining, rồi ổn định ở 2 targets Healthy. Quá trình triển khai được AWS ghi nhận hoàn tất trong 2 phút 59 giây. Em theo dõi trạng thái qua Service events và Target Group, không chỉnh sửa danh sách targets thủ công.

Phần Security Group vẫn cần được hoàn thiện vì ALB và ECS tasks đang sử dụng chung một nhóm bảo mật. Các công việc tiếp theo gồm:

1. Kiểm tra và hoàn thiện các ảnh minh chứng trong `evidence/week2/`, bổ sung URL Blob thật vào báo cáo.
2. Xem xét tách Security Group cho ALB và ECS tasks, giới hạn nguồn truy cập cổng 5000 phù hợp.
3. Kiểm thử lại website và `/health` nếu thay đổi cấu hình mạng.
4. Cập nhật README và báo cáo tiến độ trong repository.

### 9. Tổng kết

Trong Tuần 2, em đã kiểm tra cấu hình ECS hiện có và phát hiện Task Definition Revision 1 chưa khai báo Task role khi đối chiếu JSON. Em tạo Revision 2, đặt cả Task role và Task execution role thành `LabRole`, sau đó cập nhật ECS Service sang revision mới.

Em theo dõi quá trình rolling update qua Service deployment timeline, events và Target Group. Tại thời điểm kiểm tra, số targets chuyển từ 4 xuống 3 rồi về 2 Healthy; deployment hoàn tất trong 2 phút 59 giây. Sau khi cập nhật, Service duy trì 2 tasks, website vẫn truy cập được qua DNS của ALB và CloudWatch Logs ghi nhận các health check thành công.

Trong quá trình kiểm tra mạng, em phát hiện ALB và ECS tasks đang sử dụng chung Security Group và ghi nhận đây là phần cần xem xét thêm. Em tiếp tục hoàn thiện minh chứng, bổ sung liên kết Blob đến các file trong repository và cập nhật báo cáo theo đúng kết quả thực tế.

Trong Tuần 1 và Tuần 2, em (24110208) trực tiếp thực hiện công việc. Thành viên 24110380 chưa trực tiếp tham gia triển khai trong hai tuần này, nên em không ghi nhận giờ làm hoặc kết quả chưa phát sinh của thành viên đó.