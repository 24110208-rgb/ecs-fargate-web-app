# BÁO CÁO TIẾN ĐỘ TUẦN 4

## Đề tài: Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate

### 1. Thông tin đề tài

| Thông tin | Nội dung |
|---|---|
| Tên đề tài | Container hóa ứng dụng web và triển khai lên Amazon ECS Fargate |
| Nhóm | Containers |
| Môn học | Cloud - Dot 1 - 2026–2027 |
| Giảng viên hướng dẫn | Huỳnh Xuân Phụng |
| Nền tảng triển khai | Amazon Web Services (AWS) |
| AWS Region | `us-east-1` – US East (N. Virginia) |
| Thành viên 1 | 24110208 – Đỗ Lê Gia Hân |
| Thành viên 2 | 24110380 |

### 2. Phân công công việc và thời gian thực hiện

Trong tuần 4, em (mã sinh viên 24110208 – Đỗ Lê Gia Hân) trực tiếp thực hiện các công việc kỹ thuật của dự án, bao gồm kiểm thử hệ thống AWS, build và kiểm thử Docker image trên CloudShell, push image lên ECR, cập nhật repository GitHub, tạo S3 bucket và rà soát tài nguyên sau khi kiểm thử.

Thành viên 24110380 hỗ trợ em rà soát, sắp xếp và hoàn thiện nội dung báo cáo tiến độ tuần 4 trong 30 phút.

Chi tiết công việc của từng thành viên:

| Mã sinh viên | Thành viên | Nội dung công việc | Kết quả đạt được | Thời gian |
|---|---|---|---|---:|
| 24110208 | Đỗ Lê Gia Hân | Kiểm thử ECS Service, tăng Desired tasks lên 2; kiểm tra trạng thái hai tasks, Target Group, trang chủ và endpoint `/health` qua ALB. | Xác nhận 2/2 tasks Running, 2/2 targets Healthy; trang chủ và `/health` phản hồi thành công. | 45 phút |
| 24110208 | Đỗ Lê Gia Hân | Kiểm tra CloudWatch Logs, Dashboard, Alarm và cấu hình inbound của hai Security Groups. | Xác nhận logs của hai tasks; Dashboard có dữ liệu; Alarm ở trạng thái OK; rà soát luồng truy cập ALB đến ECS Tasks. | 30 phút |
| 24110208 | Đỗ Lê Gia Hân | Clone repository trên CloudShell; kiểm tra Dockerfile, requirements và cập nhật `.dockerignore`; build Docker image `week4-cloudshell`. | Build image thành công; Docker build context giảm còn khoảng 4.92 KB. | 60 phút |
| 24110208 | Đỗ Lê Gia Hân | Chạy container thử nghiệm, gọi endpoint `/health`, kiểm tra Docker Logs và xóa container sau khi thử nghiệm. | Container chạy được; endpoint trả về HTTP 200 và `{"status":"healthy"}`; container thử nghiệm được xóa. | 30 phút |
| 24110208 | Đỗ Lê Gia Hân | Đăng nhập ECR, gắn tag và push image `week4-cloudshell`; kiểm tra image tags và thông tin image trên ECR; đăng xuất ECR. | Image `week4-cloudshell` được push thành công; ECR có hai tags `week1` và `week4-cloudshell`. | 30 phút |
| 24110208 | Đỗ Lê Gia Hân | Cập nhật README và `.dockerignore`; commit thay đổi, tạo Pull Request #3, xử lý quy tắc bảo vệ nhánh và merge vào `main`; đồng bộ CloudShell với `origin/main`. | Pull Request #3 được merge; commit trên `main` là `59ca325`; working tree sạch sau khi đồng bộ. | 60 phút |
| 24110208 | Đỗ Lê Gia Hân | Tạo S3 bucket, kiểm tra Block Public Access, mã hóa SSE-S3 và tags; rà soát ECR, CloudWatch, ALB, ngân sách Learner Lab; scale ECS Service về 0. | S3 bucket được tạo và cấu hình riêng tư; ECS Service trở về Desired 0 / Running 0; hoàn tất rà soát tài nguyên. | 45 phút |
| 24110380 | Thành viên 2 | Hỗ trợ rà soát, sắp xếp và hoàn thiện nội dung báo cáo tiến độ tuần 4; đối chiếu các hạng mục công việc và minh chứng cần trình bày. | Hỗ trợ hoàn thiện nội dung báo cáo tuần 4. | 30 phút |

**Tổng thời gian thực hiện của Đỗ Lê Gia Hân: 5 giờ.**

**Tổng thời gian thực hiện của thành viên 24110380: 30 phút.**

**Tổng thời gian thực hiện của nhóm trong tuần 4: 5 giờ 30 phút.**

### 3. Mục tiêu tuần 4

Trong tuần 4, em tập trung kiểm tra lại các thành phần đã triển khai, bổ sung quy trình build image trên AWS CloudShell và hoàn thiện tài liệu dự án.

Các nội dung chính gồm:

- Kiểm thử ứng dụng khi ECS Service chạy hai tasks.
- Kiểm tra hoạt động của Application Load Balancer và Target Group.
- Kiểm tra endpoint `/health` và CloudWatch Logs.
- Build Docker image trên AWS CloudShell và chạy thử container.
- Push image mới lên Amazon ECR.
- Cập nhật README và `.dockerignore` trên GitHub.
- Tạo S3 bucket riêng tư cho tài liệu dự án.
- Rà soát trạng thái và chi phí tài nguyên AWS.
- Scale ECS Service về 0 sau khi hoàn thành kiểm thử.

### 4. Nội dung công việc đã thực hiện

#### 4.1. Kiểm thử ECS Fargate và Application Load Balancer

Trước khi kiểm thử, ECS Service `ecs-fargate-web-app-service` được đặt Desired tasks = 0. Em cập nhật số lượng mong muốn lên 2 để kiểm tra hoạt động của ứng dụng.

Kết quả kiểm thử:

| Thông số | Kết quả |
|---|---:|
| ECS Cluster | `ecs-fargate-web-app-cluster` |
| ECS Service | `ecs-fargate-web-app-service` |
| Task Definition | `ecs-fargate-web-app-task:2` |
| Desired tasks | 2 |
| Running tasks | 2 |
| Pending tasks | 0 |
| Deployment status | Success |
| Healthy targets | 2 |
| Unhealthy targets | 0 |

Trong Target Group `ecs-fargate-web-app-tg`, cả hai targets đều ở trạng thái Healthy. Em truy cập ứng dụng thông qua DNS của ALB và xác nhận trang chủ hiển thị nội dung `ECS Fargate Web App`.

Endpoint `/health` trả về HTTP 200 với nội dung:

```json
{
  "status": "healthy"
}
```

Kết quả cho thấy ứng dụng nhận request thông qua ALB và endpoint kiểm tra sức khỏe hoạt động bình thường.

#### 4.2. Rà soát Security Groups

Em kiểm tra quy tắc inbound của hai Security Groups đang sử dụng:

| Thành phần | Security Group ID | Quy tắc inbound |
|---|---|---|
| Application Load Balancer | `sg-0691b478933950ad4` | HTTP, TCP port 80, nguồn `0.0.0.0/0` |
| ECS Tasks | `sg-051591c7c511f7c37` | TCP port 5000, nguồn là ALB Security Group |

Cấu hình này cho phép ALB tiếp nhận HTTP request từ bên ngoài, trong khi ECS Tasks chỉ nhận lưu lượng trên port 5000 từ Security Group của ALB.

Việc tách biệt hai Security Groups giúp giới hạn nguồn lưu lượng có thể truy cập trực tiếp vào ứng dụng trong container.

#### 4.3. Kiểm tra CloudWatch Logs

Em kiểm tra Log Group:

`/ecs/ecs-fargate-web-app-task`

Hai Log Streams mới tương ứng với hai ECS Tasks trong lần kiểm thử tuần 4:

- `ecs/ecs-fargate-web-app/9bb149c1516942bea2b1aec0994d4825`
- `ecs/ecs-fargate-web-app/6698641f71ec4c038ba003a844b55b9c`

Logs ghi nhận Gunicorn phiên bản 23.0.0 khởi động thành công, lắng nghe tại `0.0.0.0:5000` và chạy hai workers.

Các request đến trang chủ và endpoint `/health` được ghi nhận với phản hồi HTTP 200. Một số request đến đường dẫn không được ứng dụng hỗ trợ trả về HTTP 404 hoặc HTTP 405. Các phản hồi này không ảnh hưởng đến kết quả kiểm tra trang chủ và endpoint `/health`.

#### 4.4. Build Docker image trên AWS CloudShell

Em mở AWS CloudShell tại Region `us-east-1`, kiểm tra tài khoản AWS và phiên bản Docker, Git đang sử dụng. Sau đó, em clone repository:

`https://github.com/24110208-rgb/ecs-fargate-web-app`

Em rà soát Dockerfile và cập nhật `.dockerignore` để loại trừ các thành phần không cần thiết cho quá trình build, gồm file `.msi`, thư mục `evidence/`, `reports/` và `README.md`.

Sau khi cập nhật, Docker build context giảm còn khoảng 4.92 KB.

Em build image bằng lệnh:

```bash
docker build -t ecs-fargate-web-app:week4-cloudshell .
```

Quá trình build hoàn thành thành công. Image được tạo với tag `week4-cloudshell`; image ID cục bộ bắt đầu bằng `2bd2be3f194d`. Dung lượng image hiển thị trên Docker cục bộ khoảng 125 MB.

#### 4.5. Kiểm thử container trên CloudShell

Em chạy container thử nghiệm và ánh xạ port 5000:

```bash
docker run -d --name ecs-week4-cloudshell-test -p 5000:5000 ecs-fargate-web-app:week4-cloudshell
```

Sau đó, em gọi endpoint `http://localhost:5000/health`. Kết quả trả về HTTP 200 và nội dung:

```json
{
  "status": "healthy"
}
```

Docker Logs cũng xác nhận Gunicorn khởi động thành công và ứng dụng lắng nghe tại port 5000.

Sau khi hoàn tất, em xóa container thử nghiệm bằng lệnh:

```bash
docker rm -f ecs-week4-cloudshell-test
```

Container thử nghiệm đã được xóa; Docker image được giữ lại để push lên ECR.

#### 4.6. Push image mới lên Amazon ECR

Em đăng nhập Amazon ECR từ CloudShell bằng AWS CLI, gắn tag cho image theo địa chỉ repository và thực hiện push.

Image được lưu tại:

`729012882197.dkr.ecr.us-east-1.amazonaws.com/ecs-fargate-web-app:week4-cloudshell`

Kết quả kiểm tra repository cho thấy có hai image tags:

| Image tag | Ý nghĩa |
|---|---|
| `week1` | Image được tạo và sử dụng từ giai đoạn triển khai ban đầu |
| `week4-cloudshell` | Image được build và push từ AWS CloudShell trong tuần 4 |

ECR ghi nhận image `week4-cloudshell` có dung lượng khoảng 46.25 MB. Dung lượng này là dung lượng image được ECR ghi nhận, khác với dung lượng image cục bộ trong Docker.

**Lưu ý về trạng thái triển khai:** Image `week4-cloudshell` đã được push thành công lên ECR nhưng chưa được dùng để thay thế image của ECS Service. Task Definition Revision 2 vẫn giữ cấu hình image đã sử dụng từ giai đoạn trước. Vì vậy, kết quả tuần 4 xác nhận việc build và push image mới, không đồng nghĩa với việc đã triển khai revision mới lên ECS.

Sau khi push, em thực hiện `docker logout` khỏi ECR để xóa thông tin đăng nhập được lưu trong Docker config của CloudShell.

#### 4.7. Cập nhật README và `.dockerignore` trên GitHub

Em bổ sung README để mô tả dự án, kiến trúc triển khai, các dịch vụ AWS sử dụng, quy trình build và push Docker image, cách kiểm tra ứng dụng và nội dung quản lý tài nguyên.

Em cũng cập nhật `.dockerignore` để loại trừ các file và thư mục không cần thiết khỏi Docker build context.

Do repository bảo vệ nhánh `main`, em tạo nhánh riêng:

`docs/finalize-readme-dockerignore`

Sau đó, em commit các thay đổi và tạo Pull Request số 3. Pull Request đã được merge thành công vào nhánh `main`.

Thông tin sau khi merge:

- Pull Request: `#3`
- Commit trên `main`: `59ca325`
- Nội dung commit: `docs: improve README and optimize Docker build context`

Sau khi merge, em đồng bộ CloudShell với `origin/main`. Kết quả kiểm tra cho thấy nhánh `main` đã đồng bộ với GitHub và working tree sạch.

#### 4.8. Tạo Amazon S3 bucket

Trong tuần 4, em tạo S3 bucket riêng cho dự án với tên:

`ecs-fargate-web-app-evidence-729012882197-20261104`

Bucket được tạo tại Region `us-east-1`. Em kiểm tra và xác nhận các cấu hình:

| Thuộc tính | Cấu hình |
|---|---|
| Block Public Access | Bật cả bốn tùy chọn |
| Default encryption | SSE-S3 |
| Encryption algorithm | AES256 |
| Project tag | `ECSFargateWebApp` |
| Owner tag | `Do Le Gia Han` |

Bucket được cấu hình riêng tư, chặn truy cập công khai và sử dụng mã hóa mặc định SSE-S3.

#### 4.9. Rà soát tài nguyên, chi phí và trạng thái hệ thống

Sau khi hoàn thành kiểm thử, em rà soát lại các tài nguyên:

- ECS Service đã được scale về Desired tasks = 0; Running tasks = 0 và Pending tasks = 0.
- Service chưa có cấu hình Application Auto Scaling.
- Application Load Balancer vẫn ở trạng thái Active.
- ECR repository lưu hai image tags `week1` và `week4-cloudshell`.
- ECR chưa có Lifecycle Policy.
- CloudWatch Log Group đang đặt thời gian lưu trữ một tháng.
- CloudWatch Alarm `ECS-Fargate-UnHealthyHost-Alarm` ở trạng thái `OK`.

Tại thời điểm kiểm tra, Learner Lab hiển thị mức sử dụng ngân sách khoảng 9.4 USD trên tổng ngân sách 50 USD. Đây là chỉ số ngân sách tổng của Learner Lab, không phải báo cáo chi phí riêng của dự án.

Mặc dù ECS Service đã được scale về 0, ALB vẫn còn hoạt động để phục vụ việc kiểm tra và trình diễn. Vì vậy, em tiếp tục theo dõi chi phí của ALB và các tài nguyên liên quan trước khi kết thúc dự án.

### 5. Kết quả đạt được

Trong tuần 4, em đã đạt được các kết quả sau:

- Kiểm thử ECS Service với hai tasks Running.
- Xác nhận cả hai targets trong Target Group đều Healthy.
- Kiểm tra trang chủ và endpoint `/health` qua ALB.
- Kiểm tra CloudWatch Logs của hai tasks.
- Rà soát cấu hình Security Groups giữa ALB và ECS Tasks.
- Build Docker image thành công trên AWS CloudShell.
- Chạy thử container và xác nhận endpoint `/health` trả về HTTP 200.
- Push image tag `week4-cloudshell` lên Amazon ECR.
- Cập nhật README và `.dockerignore`, sau đó merge Pull Request vào `main`.
- Tạo S3 bucket riêng tư, bật Block Public Access và mã hóa SSE-S3.
- Scale ECS Service về 0 sau khi kiểm thử.

### 6. Khó khăn và cách xử lý

**Cập nhật repository GitHub**

Repository có quy tắc bảo vệ nhánh `main`, nên việc push trực tiếp lên nhánh chính không được chấp nhận. Em xử lý bằng cách tạo nhánh riêng, commit thay đổi, mở Pull Request và merge theo quy trình của repository.

**Tối ưu Docker build context**

Repository có một số file và thư mục không cần thiết cho quá trình build. Em bổ sung quy tắc vào `.dockerignore`; sau khi điều chỉnh, build context giảm còn khoảng 4.92 KB.

**Quản lý tài nguyên AWS**

Trong quá trình kiểm thử, em cần chạy ECS Tasks để xác nhận ứng dụng hoạt động. Sau khi kiểm tra xong, em scale Service về 0. ALB vẫn được giữ Active để phục vụ trình diễn, do đó em tiếp tục theo dõi chi phí trước khi dọn dẹp tài nguyên.

### 7. Kết luận

Trong tuần 4, em đã kiểm thử các thành phần ECS Fargate, Application Load Balancer, Target Group và CloudWatch; build Docker image trên AWS CloudShell; kiểm tra container; push image lên Amazon ECR; cập nhật tài liệu GitHub và tạo S3 bucket cho dự án.

Kết quả kiểm thử cho thấy ứng dụng hoạt động bình thường khi chạy hai tasks và cả hai targets đều Healthy. Image mới đã được lưu trong ECR dưới tag `week4-cloudshell`, nhưng chưa được triển khai thay thế image đang sử dụng bởi Task Definition Revision 2.

Sau khi hoàn thành kiểm thử, ECS Service đã được đưa về Desired tasks = 0. Các tài nguyên còn hoạt động, đặc biệt là ALB, cần tiếp tục được theo dõi và dọn dẹp phù hợp sau khi hoàn tất trình diễn.

### 8. Minh chứng

Các ảnh minh chứng tuần 4 được tổ chức trong thư mục `evidence/week4/` trên repository GitHub. Đối với từng minh chứng, em bổ sung đường dẫn GitHub dạng **blob** trỏ trực tiếp đến file ảnh tương ứng để giảng viên có thể mở và kiểm tra.

| STT | Nội dung minh chứng | File minh chứng trong repository | GitHub Blob URL |
|---:|---|---|---|
| 1 | ECS Service khi chạy hai tasks | `evidence/week4/01-final-ecs-service-2-tasks.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/01-final-ecs-service-2-tasks.png) |
| 2 | Target Group có hai targets Healthy | `evidence/week4/02-final-target-group-2-healthy.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/02-final-target-group-2-healthy.png) |
| 3 | Trang chủ ứng dụng qua ALB | `evidence/week4/03-final-homepage.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/03-final-homepage.png) |
| 4 | Endpoint `/health` trả về kết quả healthy | `evidence/week4/04-final-health-endpoint.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/04-final-health-endpoint.png) |
| 5 | CloudWatch Logs của ECS Task thứ nhất | `evidence/week4/05-final-cloudwatch-task1.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/05-final-cloudwatch-task1.png) |
| 6 | CloudWatch Logs của ECS Task thứ hai | `evidence/week4/06-final-cloudwatch-task2.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/06-final-cloudwatch-task2.png) |
| 7 | CloudWatch Dashboard theo dõi ECS và ALB | `evidence/week4/07-final-cloudwatch-dashboard.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/07-final-cloudwatch-dashboard.png) |
| 8 | CloudWatch Alarm | `evidence/week4/08-final-cloudwatch-alarm.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/08-final-cloudwatch-alarm.png) |
| 9 | Inbound rule của Task Security Group | `evidence/week4/09a-final-task-security-group.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/09a-final-task-security-group.png) |
| 10 | Inbound rule của ALB Security Group | `evidence/week4/09b-final-alb-security-group.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/09b-final-alb-security-group.png) |
| 11 | ECS Service sau khi scale về 0 | `evidence/week4/10-final-ecs-service-scaled-zero.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/10-final-ecs-service-scaled-zero.png) |
| 12 | Trạng thái Service Auto Scaling | `evidence/week4/11-final-service-autoscaling-not-configured.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/11-final-service-autoscaling-not-configured.png) |
| 13 | Mức sử dụng ngân sách Learner Lab | `evidence/week4/12-final-learner-lab-budget.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/12-final-learner-lab-budget.png) |
| 14 | Thông tin Application Load Balancer | `evidence/week4/13-final-alb-resource-review.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/13-final-alb-resource-review.png) |
| 15 | Các image tags trong Amazon ECR | `evidence/week4/14-final-ecr-images.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/14-final-ecr-images.png) |
| 16 | CloudWatch Log Group và thời gian lưu trữ | `evidence/week4/15-final-cloudwatch-log-group-review.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/15-final-cloudwatch-log-group-review.png) |
| 17 | Trạng thái ECR Lifecycle Policy | `evidence/week4/16-final-ecr-lifecycle-policy.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/16-final-ecr-lifecycle-policy.png.png) |
| 18 | AWS CloudShell và môi trường build | `evidence/week4/17-final-cloudshell-environment.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/17-final-cloudshell-environment.png) |
| 19 | Quá trình Docker build trên CloudShell | `evidence/week4/18-final-cloudshell-docker-build.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/18-final-cloudshell-docker-build.png) |
| 20 | Kiểm thử endpoint của container trên CloudShell | `evidence/week4/19-final-cloudshell-container-health.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/19-final-cloudshell-container-health.png) |
| 21 | Docker Logs của container thử nghiệm | `evidence/week4/20-final-cloudshell-container-logs.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/20-final-cloudshell-container-logs.png) |
| 22 | Kết quả push image lên Amazon ECR | `evidence/week4/21-final-cloudshell-push-ecr.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/21-final-cloudshell-push-ecr.png) |
| 23 | Cấu hình bảo mật, tags và mã hóa của S3 bucket | `evidence/week4/22-final-s3-bucket-security-tags-encryption.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/22-final-s3-bucket-security-tags-encryption.png) |
| 24 | Pull Request #3 cập nhật README và `.dockerignore` đã merge | `evidence/week4/23-final-github-pr-merged.png` | [Xem](https://github.com/24110208-rgb/ecs-fargate-web-app/blob/main/evidence/week4/23-final-github-pr-merged.png) |

### 8.1. Lịch sử commit tuần 4

| Commit | Ngày | Nội dung | Liên kết |
|---|---|---|---|
| `a82cb72` | 04/11/2026 | Add week4 evidence, reports and architecture diagram | [a82cb72c](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/a82cb72c2d6023632f121c07c5bacc6ff4435d96) |
| `4875bb4` | 04/11/2026 | docs: add blob links for week4 evidence in report | [4875bb45](https://github.com/24110208-rgb/ecs-fargate-web-app/commit/4875bb4553406d6e60b13f7227a667220470ec3b) |

### 9. Khai báo sử dụng công cụ AI

Trong quá trình thực hiện dự án và hoàn thiện báo cáo tuần 4, em có sử dụng công cụ AI để tham khảo, hỗ trợ giải thích kỹ thuật, kiểm tra lỗi và trình bày nội dung báo cáo. Việc sử dụng AI được khai báo cụ thể như sau:

| Nội dung                                     | Thông tin khai báo                                                                                                                                                                                                                                                                                      |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Công cụ AI                                   | ChatGPT                                                                                                                                                                                                                                                                                                 |
| Phiên bản / Model                            | GPT-6                                                                                                                                                                                                                                                                                                   |
| Prompt đã sử dụng                            | Hỗ trợ hướng dẫn kiểm thử ứng dụng trên Amazon ECS Fargate; giải thích và xử lý các bước build Docker image trên AWS CloudShell, kiểm thử container và push image lên Amazon ECR; hỗ trợ rà soát README, `.dockerignore` và xây dựng nội dung báo cáo tiến độ tuần 4.                                   |
| Nội dung AI tạo ra                           | Các hướng dẫn thao tác AWS, giải thích lệnh Docker và AWS CLI, gợi ý xử lý các vấn đề trong quá trình thực hiện, bố cục và bản nháp nội dung báo cáo tuần 4.                                                                                                                                            |
| Phần em đã kiểm tra, chỉnh sửa và hoàn thiện | Em trực tiếp thực hiện các thao tác trên AWS và GitHub, kiểm tra kết quả thực tế, đối chiếu thông tin tài nguyên, điều chỉnh nội dung báo cáo theo tiến độ đã thực hiện, bổ sung số liệu, worklog và đường dẫn minh chứng. Em chịu trách nhiệm về tính chính xác của nội dung báo cáo và kết quả dự án. |

Em sử dụng AI như một công cụ hỗ trợ trong quá trình học tập và thực hiện dự án. Các nội dung do AI đề xuất đều được em xem xét, đối chiếu với kết quả thực tế trước khi sử dụng.
