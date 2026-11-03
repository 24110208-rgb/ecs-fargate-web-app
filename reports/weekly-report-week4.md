# BÁO CÁO TIẾN ĐỘ TUẦN 4

## Đề tài: Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate


### 1. Thông tin đề tài

| Thông tin | Nội dung |
|---|---|
| Tên đề tài | Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate |
| Nhóm | Containers |
| Môn học | Cloud - Dot 1 - 2026–2027 |
| Giảng viên hướng dẫn | Huỳnh Xuân Phụng |
| Nền tảng triển khai | Amazon Web Services (AWS) Learner Lab |
| AWS Region | `us-east-1` – US East (N. Virginia) |
| Repository Git | [ecs-fargate-web-app](https://github.com/24110208-rgb/ecs-fargate-web-app) |
| Thành viên thực hiện | 24110208 – Đỗ Lê Gia Hân |
| Thành viên còn lại | 24110380 – Nguyễn Quốc Việt|
| Ngày cập nhật | 03/11/2026 |

### 2. Mục tiêu tuần 4

Tuần 4 tập trung hoàn tất kiểm thử tổng thể, rà soát chi phí, dọn dẹp hoặc đưa tài nguyên về trạng thái tiết kiệm chi phí, hoàn thiện báo cáo và chuẩn bị demo.

- Kiểm tra khả năng triển khai ECS Service từ trạng thái không chạy task lên hai task.
- Kiểm tra trạng thái triển khai, Target Group, trang chủ và endpoint `/health` qua ALB.
- Đối chiếu log ứng dụng và trạng thái giám sát CloudWatch.
- Kiểm tra phần tổng quan chi phí trong AWS Billing and Cost Management và ghi nhận các giới hạn của dữ liệu hiển thị.
- Scale ECS Service về 0 sau buổi kiểm thử; rà soát các tài nguyên còn tồn tại và lựa chọn dọn dẹp phù hợp với kế hoạch demo.
- Chuẩn bị trình tự demo và tập hợp minh chứng tổng kết.

### 3. Phân công công việc và thời gian thực hiện

| Mã sinh viên | Thành viên | Công việc tuần 4 | Kết quả | Số giờ thực tế |
|---|---|---|---|---:|
| 24110208 | Đỗ Lê Gia Hân | Không tham gia trực tiếp vào công việc phân công tuần 4 | Không có |
| 24110380 | Nguyễn Quốc Việt | Kiểm thử tổng thể, rà soát chi phí, dọn dẹp hoặc đưa tài nguyên về trạng thái tiết kiệm chi phí, hoàn thiện báo cáo theo các tiêu chí đã đặt ra | Đã hoàn thành kiểm thử triển khai ECS Service, kiểm tra trạng thái, đối chiếu log ứng dụng, giám sát, kiểm tra chi phí, dọn dẹp tài nguyên | 4 giờ |

Tổng thời gian làm việc tuần 4: 4 giờ 

### 4. Nội dung công việc và kết quả kiểm thử

#### 4.1. Kiểm tra trạng thái triển khai ECS

Ngày 02/11/2026, sau khi cập nhật Desired Count lên 2 để thực hiện kiểm thử cuối, ECS Service đạt trạng thái ổn định. AWS ghi nhận hai task đang chạy, không có task chờ và deployment hoàn tất.

| Thành phần/thông số | Giá trị đã xác nhận |
|---|---|
| ECS Cluster | `ContainerCK_Cluster` |
| ECS Service | `ecs-fargate-web-app-task-service-w7ynoxn2` |
| Task Definition đã kiểm tra | `ecs-fargate-web-app-task:1` |
| Desired / Running / Pending | `2 / 2 / 0` |
| Rollout state | `COMPLETED` |
| Target Group | `ecs-fargate-web-app-tg` |
| Container port | `5000` |
| Kiểm tra gần nhất | 02/11/2026; service đạt steady state |

Trong lúc thay task, một số target cũ xuất hiện ở trạng thái `draining`; sau khi deployment ổn định, hai target mới được xác nhận `healthy`.

#### 4.2. Kiểm thử ứng dụng qua Application Load Balancer

Ứng dụng được truy cập qua DNS của ALB:

`http://ecs-fargate-web-app-alb-1816018687.us-east-1.elb.amazonaws.com`

Các kiểm tra đã thực hiện:

| Kiểm tra | Kết quả quan sát |
|---|---|
| Mở trang chủ `/` | HTTP `200 OK`; trang HTML của ứng dụng Flask được trả về |
| Mở endpoint `/health` | HTTP `200 OK`; nội dung `{"status":"healthy"}` |
| Kiểm tra Target Group | Hai target mới ở trạng thái `healthy` sau khi service ổn định |
| Kiểm tra ECS deployment | Desired `2`, Running `2`, Pending `0`, rollout `COMPLETED` |

Như vậy, tại thời điểm kiểm tra, luồng từ trình duyệt → ALB → Target Group → ECS Fargate task → Flask/Gunicorn hoạt động thành công.

#### 4.3. Đối chiếu CloudWatch Logs và giám sát

Log Group đã kiểm tra: `/ecs/ecs-fargate-web-app-task`. Log stream ghi nhận Gunicorn lắng nghe tại `0.0.0.0:5000`, các yêu cầu ELB health check `GET /health` trả HTTP 200. Retention đã được cấu hình 30 ngày.

Các kết quả giám sát đã có từ tuần 3 và được đối chiếu trong quá trình tổng kết:

- CloudWatch Dashboard `ECS-Fargate-Monitoring` tồn tại.
- Alarm `ECS-Fargate-UnHealthyHost-Alarm` đã chuyển sang trạng thái `OK`.
- Service và Target Group hoạt động tốt tại thời điểm chạy kiểm thử cuối.

**Lưu ý:** Dashboard/Alarm là minh chứng giám sát cấu hình và trạng thái tại thời điểm chụp; không thay thế cho việc ghi nhận số liệu chi phí hoặc cam kết mức sẵn sàng production.

#### 4.4. Rà soát chi phí

Em mở trang **Billing and Cost Management home** và xem được phần Cost summary. Tại thời điểm chụp ngày 02/11/2026, trang hiển thị chi phí từ đầu tháng là `$0.00`; chi phí cùng kỳ tháng trước (01–02/10/2026) cũng là `$0.00`.

| Hạng mục | Kết quả hiển thị |
|---|---|
| Month-to-date cost | `$0.00` (tháng 11/2026, tại thời điểm chụp) |
| Last month's cost for same time period | `$0.00` (01–02/10/2026) |
| Forecast cho tháng hiện tại | Chưa có dữ liệu dự báo; trang báo không đủ dữ liệu lịch sử để dự báo |
| Budgets | Chưa thiết lập Budget |
| Cost Anomaly Detection | Chưa thiết lập monitor |

![AWS Billing and Cost Management hiển thị tổng chi phí tháng hiện tại là $0.00](../evidence/week4/09-billing-cost-summary.png)

#### 4.5. Tối ưu chi phí và rà soát dọn dẹp tài nguyên

Sau khi hoàn tất kiểm thử tổng thể, em cập nhật ECS Service về `Desired Count = 0`. Ảnh chụp AWS Console ngày 02/11/2026 cho thấy Service vẫn ở trạng thái `Active`, deployment `Success`, nhưng có `0 running` và `0 pending` task. Việc scale về 0 dừng các Fargate tasks sau buổi thực hành; các tài nguyên nền tảng được giữ lại để có thể khởi chạy lại và phục vụ demo.

| Tài nguyên | Trạng thái đã biết | Hành động tối ưu |
|---|---|---|
| ECS Service tasks | Đã scale về `0` Desired, `0` Running, `0` Pending; Service Active, deployment Success | Đã dừng tasks sau buổi kiểm thử; khởi chạy lại khi demo |
| ECS Service/Cluster | Còn tồn tại để có thể khởi chạy lại | Giữ lại phục vụ demo; chưa xóa |
| Application Load Balancer và Target Group | Còn tồn tại | Có thể tiếp tục phát sinh chi phí khi còn tồn tại; xóa nếu đã kết thúc demo và không cần URL |
| ECR Repository/Image | Còn image `week1` theo Task Definition đã kiểm tra | Xóa image/repository chỉ sau khi xác nhận không còn cần triển khai lại |
| CloudWatch Log Group | `/ecs/ecs-fargate-web-app-task`, retention 30 ngày | Giữ retention 30 ngày trong thời gian cần minh chứng; xóa Log Group chỉ khi không còn cần log |
| Dashboard và Alarm | Đã tạo | Giữ cho báo cáo/demo hoặc xóa sau khi kết thúc dự án nếu không còn nhu cầu |
| Security Groups và networking | Có SG riêng cho ALB/task theo các kiểm tra trước | Chỉ xóa sau khi xóa các tài nguyên còn tham chiếu đến chúng |

![ECS Service sau khi scale về 0 task](../evidence/week4/10-ecs-service-scaled-to-zero.png)

**Phạm vi dọn dẹp đã xác nhận:** Đã dừng Fargate tasks bằng cách scale Service về 0. Chưa thực hiện xóa toàn bộ ALB, ECR, CloudWatch, Cluster hoặc Service; các thành phần này được giữ lại để hỗ trợ demo. Do ALB và các tài nguyên khác vẫn tồn tại, trạng thái scale Service về 0 không đồng nghĩa toàn bộ hạ tầng đã bị xóa hoặc chắc chắn không còn chi phí.

#### 4.6. Kịch bản demo tổng thể

Trình tự demo dự kiến, dùng AWS Console và trình duyệt:

1. Giới thiệu kiến trúc: ECR lưu image, ECS/Fargate chạy container, ALB phân phối request, CloudWatch nhận log và metrics.
2. Mở ECR repository và giới thiệu image đang được Task Definition sử dụng.
3. Mở ECS Cluster/Service, chỉ ra Task Definition, Desired/Running tasks và deployment state.
4. Mở Target Group để cho thấy các task đang Healthy.
5. Mở DNS ALB trên trình duyệt, kiểm tra trang chủ và `/health`.
6. Mở CloudWatch Logs để chỉ ra Gunicorn khởi động và log `GET /health` HTTP 200.
7. Mở Dashboard và Alarm, giải thích CPU/Memory, Healthy/UnHealthy host và trạng thái Alarm.
8. Kết thúc demo bằng việc scale Service về 0 và kiểm tra không còn task chạy.

### 5. Tổng hợp kết quả tuần 4

| STT | Hạng mục | Kết quả hiện có | Trạng thái báo cáo |
|---:|---|---|---|
| 1 | ECS Service deployment | `2` Desired, `2` Running, `0` Pending; rollout `COMPLETED` ngày 02/11/2026 | Đã kiểm tra |
| 2 | Target Group health | Hai target mới `healthy` sau khi ổn định | Đã kiểm tra |
| 3 | Trang chủ qua ALB | HTTP 200 | Đã kiểm tra |
| 4 | Endpoint `/health` | HTTP 200, `{"status":"healthy"}` | Đã kiểm tra |
| 5 | CloudWatch Logs | Có log Gunicorn và health check HTTP 200; retention 30 ngày | Đã kiểm tra từ tuần 3/đối chiếu |
| 6 | Dashboard và Alarm | Dashboard có ảnh tuần 4; Alarm trạng thái `OK` theo lần kiểm tra đã cung cấp | Dashboard có minh chứng; Alarm dùng kết quả kiểm tra tuần 3 |
| 7 | Billing cost summary | Month-to-date `$0.00`; cùng kỳ tháng trước `$0.00`; forecast chưa đủ dữ liệu | Đã xem và có ảnh minh chứng; chưa có phân bổ theo tài nguyên dự án |
| 8 | Scale về 0 sau kiểm thử cuối | Desired `0`, Running `0`, Pending `0`; Service Active, deployment Success | Đã thực hiện và có ảnh minh chứng |
| 9 | Dọn dẹp tài nguyên | Fargate tasks đã dừng; ALB, ECR, CloudWatch, Cluster/Service vẫn được giữ để demo | Đã tối ưu compute; chưa teardown toàn bộ |
| 10 | Báo cáo/demo | Có bản nháp báo cáo và kịch bản demo trong file này | Chờ sinh viên rà soát |

### 6. Minh chứng tuần 4

Ảnh chụp từ `C:\Users\viet0\Pictures\Screenshots` đã được đưa vào `evidence/week4/` và liên kết dưới đây để có thể xem cùng báo cáo.

| STT | Tên file | Nội dung minh chứng | Liên kết |
|---:|---|---|---|
| 01 | `01-ecs-service-2-running-healthy.png` | ECS Service: Desired 2, Running 2, Pending 0; 2 target Healthy trước khi kết thúc kiểm thử | [Xem ảnh](../evidence/week4/01-ecs-service-2-running-healthy.png) |
| 02 | `02-ecs-cluster-overview-2-running.png` | Tổng quan Cluster có 2 task đang chạy trong bước kiểm thử | [Xem ảnh](../evidence/week4/02-ecs-cluster-overview-2-running.png) |
| 03 | `03-alb-homepage.png` | Trang chủ mở qua DNS ALB | [Xem ảnh](../evidence/week4/03-alb-homepage.png) |
| 04 | `04-target-group-2-healthy.png` | Target Group có hai target Healthy, không có Unhealthy target | [Xem ảnh](../evidence/week4/04-target-group-2-healthy.png) |
| 05 | `05-health-endpoint.png` | Endpoint `/health` trả `{"status":"healthy"}` | [Xem ảnh](../evidence/week4/05-health-endpoint.png) |
| 06 | `06-cloudwatch-task-log-1.png` | Log khởi động Gunicorn và health check HTTP 200 của task thứ nhất | [Xem ảnh](../evidence/week4/06-cloudwatch-task-log-1.png) |
| 07 | `07-cloudwatch-task-log-2.png` | Log khởi động Gunicorn và health check HTTP 200 của task thứ hai | [Xem ảnh](../evidence/week4/07-cloudwatch-task-log-2.png) |
| 08 | `08-cloudwatch-dashboard.png` | Dashboard hiển thị CPU/Memory, Healthy/UnHealthy host và RequestCountPerTarget | [Xem ảnh](../evidence/week4/08-cloudwatch-dashboard.png) |
| 09 | `09-billing-cost-summary.png` | Billing home: MTD `$0.00`, cùng kỳ tháng trước `$0.00`; dự báo chưa đủ dữ liệu | [Xem ảnh](../evidence/week4/09-billing-cost-summary.png) |
| 10 | `10-ecs-service-scaled-to-zero.png` | ECS Service Active, deployment Success, Desired/Running/Pending đều bằng 0 | [Xem ảnh](../evidence/week4/10-ecs-service-scaled-to-zero.png) |


### 7. Khó khăn, giới hạn và cách xử lý

- Các lần đầu deployment gặp lỗi health check do cấu hình Security Group của ALB/task chưa phù hợp. Sau khi ALB dùng Security Group dành cho ALB và task chỉ nhận TCP 5000 từ Security Group của ALB, ứng dụng đã trả HTTP 200 và target chuyển Healthy.
- Trang Billing home hiện hiển thị Cost summary, nhưng trang báo cáo Cost Explorer trước đó từng báo thiếu quyền `ce:DescribeReport`. Báo cáo ghi nhận đúng số tổng quan `$0.00` trong ảnh và phân biệt rõ đây chưa phải phân bổ chi phí theo từng tài nguyên dự án.
- Tên cluster và service trong một số báo cáo tuần trước khác với tài nguyên thực tế được xác nhận sau đó. Báo cáo tuần 4 sử dụng `ContainerCK_Cluster` và `ecs-fargate-web-app-task-service-w7ynoxn2` theo kết quả truy vấn mới nhất đã gửi.
- Sau lần kiểm thử tổng thể, Desired Count đã được đưa về 0; ảnh ECS Console xác nhận không còn task chạy.
- Các tài nguyên nền tảng như ALB, ECR, CloudWatch, Cluster và Service vẫn được giữ để phục vụ demo; báo cáo không ghi nhận đã teardown toàn bộ hạ tầng.

### 8. Khai báo sử dụng AI

| Công cụ | Nội dung được AI hỗ trợ | Phần sinh viên tự thực hiện và xác minh |
|---|---|---|
| ChatGPT/Codex | Hướng dẫn xử lý các vấn đề AWS được trao đổi trong quá trình làm lab; giải thích trạng thái ECS, ALB, CloudWatch và Billing; hỗ trợ xây dựng kịch bản kiểm thử/demo; soạn thảo, biên tập báo cáo tuần 4 và sắp xếp danh mục ảnh minh chứng dựa trên thông tin, ảnh chụp do sinh viên cung cấp | Thao tác trên AWS Console/CloudShell; chạy kiểm thử; chụp và cung cấp ảnh minh chứng; đối chiếu kết quả thực tế và quyết định nội dung cuối cùng của báo cáo |

AI không đăng nhập vào tài khoản AWS, không thực hiện thay đổi tài nguyên AWS và không tự tạo số liệu kiểm thử hoặc chi phí. Sinh viên chịu trách nhiệm kiểm tra tính chính xác của nội dung, hiểu các bước triển khai và giải thích được kết quả khi báo cáo hoặc vấn đáp.

### 9. Kết luận tuần 4

Trong lần kiểm thử tổng thể ngày 02/11/2026, ECS Service đạt trạng thái ổn định với hai task đang chạy. Hai target mới được xác nhận Healthy, trang chủ qua ALB trả HTTP 200, endpoint `/health` trả `{"status":"healthy"}`, và CloudWatch Logs ghi nhận health check thành công. Dashboard giám sát đã tồn tại và Alarm đã được xác nhận ở trạng thái OK trong lần kiểm tra trước.


