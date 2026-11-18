# Todo Management UI

แอปจัดการงาน (task) ขนาดเล็ก ทำด้วย **Rails 8.1 และ Hotwire** หน้าเว็บอัปเดตได้โดยไม่ต้อง reload และเมื่อมีการเปลี่ยนแปลง ทุก browser ที่เปิดหน้านี้อยู่จะเห็นทันที JavaScript ที่เขียนเองมีแค่ Stimulus controller ตัวเดียว

โปรเจกต์นี้ทำขึ้นเพื่อฝึก Hotwire โดยยึดหลัก "server first" คือทุกฟีเจอร์ให้ Rails สร้าง HTML ส่งมา แล้ว browser แค่เอาไปวางในหน้า

## สารบัญ

- [ฟีเจอร์](#ฟีเจอร์)
- [เครื่องมือที่ใช้](#เครื่องมือที่ใช้)
- [เริ่มต้นใช้งาน](#เริ่มต้นใช้งาน)
- [ใช้ Hotwire ตรงไหนบ้าง](#ใช้-hotwire-ตรงไหนบ้าง)
- [โครงสร้างโปรเจกต์](#โครงสร้างโปรเจกต์)
- [ตรวจคุณภาพโค้ด](#ตรวจคุณภาพโค้ด)

## ฟีเจอร์

- **เพิ่ม task** แถวใหม่ขึ้นท้ายรายการ ตัวเลขสถิติอัปเดต ฟอร์มถูกล้าง และ cursor กลับไปที่ช่องกรอก พิมพ์ task ต่อไปได้ทันที
- **เปลี่ยนสถานะ** กดวงกลมหน้าแถวเพื่อวนสถานะ Todo → Doing → Done
- **แก้ชื่อ task ในแถว** กดไอคอนดินสอ แถวนั้นจะเปลี่ยนเป็นฟอร์มแก้ชื่อ กด Save เพื่อบันทึก หรือ Cancel เพื่อยกเลิก
- **ลบ task** มีกล่องถามยืนยันก่อนลบ
- **กรองรายการ** All / Todo / Done ได้ทันที โดยไม่ส่ง request ไปที่ server
- **อัปเดตแบบ real-time** เปิดหน้าเว็บใน 2 browser แล้วแก้ข้อมูลฝั่งหนึ่ง อีกฝั่งจะเห็นทันที
- **ใช้ได้แม้ปิด JavaScript** เพิ่ม เปลี่ยนสถานะ แก้ชื่อ และลบ ยังทำงานได้แบบโหลดหน้าใหม่ตามปกติ
- **รองรับ accessibility** ปุ่มไอคอนมี label ให้ screen reader อ่าน ข้อความ error ถูกอ่านออกเสียง และ focus ring เป็นแบบเดียวกันทั้งแอป

## เครื่องมือที่ใช้

| ส่วน | เครื่องมือ |
| --- | --- |
| Backend | Ruby 4.0, [Rails 8.1](https://rubyonrails.org/), PostgreSQL 18 |
| Frontend | [Turbo](https://turbo.hotwired.dev/) (Drive, Frames, Streams), [Stimulus](https://stimulus.hotwired.dev/), [Tailwind CSS](https://tailwindcss.com/) |
| Real-time และ background job | Action Cable บน [Solid Cable](https://github.com/rails/solid_cable), [Solid Queue](https://github.com/rails/solid_queue) |
| Assets | esbuild ผ่าน `jsbundling-rails`, Tailwind ผ่าน `cssbundling-rails`, Propshaft |
| สภาพแวดล้อมสำหรับพัฒนา | Docker Compose |

## เริ่มต้นใช้งาน

### สิ่งที่ต้องมี

- [Docker](https://docs.docker.com/get-docker/) พร้อม Docker Compose
- port `3000` และ `5433` ในเครื่องต้องว่าง

ไม่ต้องติดตั้ง Ruby, Node หรือ PostgreSQL ในเครื่อง เพราะ Docker เตรียมไว้ให้แล้ว

### รันแอป

```bash
git clone https://github.com/taechonlakon-alt/hotwire-bootcamp.git
cd hotwire-bootcamp
docker compose up --build
```

แล้วเปิด <http://localhost:3000>

การรันครั้งแรก container จะติดตั้ง gem และ package สร้างฐานข้อมูล และใส่ task ตัวอย่าง 3 รายการให้ จึงใช้เวลานานกว่าครั้งต่อไป

`bin/dev` จะรัน 4 process ใน container `web` (ดู [`Procfile.dev`](Procfile.dev))

| Process | หน้าที่ |
| --- | --- |
| `web` | Rails server |
| `js` | build JavaScript ใหม่เมื่อไฟล์เปลี่ยน |
| `css` | build Tailwind CSS ใหม่เมื่อไฟล์เปลี่ยน |
| `worker` | Solid Queue worker สำหรับส่ง broadcast แบบ real-time |

### คำสั่งที่ใช้บ่อย

```bash
docker compose exec web bin/rails console   # เปิด Rails console
docker compose exec web bin/rails db:seed   # ใส่ task ตัวอย่างอีกครั้ง (รันซ้ำได้ ไม่สร้างซ้ำ)
docker compose down                         # หยุดแอป
```

ถ้า port `5433` ถูกใช้อยู่ ให้ตั้งค่า `DB_HOST_PORT` เป็น port อื่นก่อนรัน `docker compose up`

## ใช้ Hotwire ตรงไหนบ้าง

แต่ละฟีเจอร์เลือกใช้เครื่องมือของ Hotwire ที่ง่ายที่สุดที่ทำงานนั้นได้

| ฟีเจอร์ | เครื่องมือ | ไฟล์ |
| --- | --- | --- |
| ส่งฟอร์มและกดลิงก์โดยไม่ reload หน้า | Turbo Drive | ใช้กับทั้งแอปโดยอัตโนมัติ |
| แต่ละแถวของ task | Turbo Frame (`dom_id(task)`) | [`_task.html.erb`](app/views/tasks/_task.html.erb) |
| เพิ่ม: ต่อแถวใหม่ อัปเดตสถิติ ล้างฟอร์ม | Turbo Stream | [`create.turbo_stream.erb`](app/views/tasks/create.turbo_stream.erb) |
| เปลี่ยนสถานะหรือแก้ชื่อ: แทนที่แถวและสถิติ | Turbo Stream | [`update.turbo_stream.erb`](app/views/tasks/update.turbo_stream.erb) |
| ฟอร์มแก้ชื่อในแถว | Turbo Frame | [`edit.html.erb`](app/views/tasks/edit.html.erb), [`_edit_form.html.erb`](app/views/tasks/_edit_form.html.erb) |
| ลบ: เอาแถวออก อัปเดตสถิติ | Turbo Stream | [`destroy.turbo_stream.erb`](app/views/tasks/destroy.turbo_stream.erb) |
| อัปเดตให้ browser อื่นแบบ real-time | Broadcasting | [`task.rb`](app/models/task.rb), `turbo_stream_from "tasks"` |
| ถามยืนยันก่อนลบ | `data-turbo-confirm` | [`_task.html.erb`](app/views/tasks/_task.html.erb) |
| กรอง All / Todo / Done | Stimulus `task-filter` | [`task_filter_controller.js`](app/javascript/controllers/task_filter_controller.js) |

รายละเอียดเพิ่มเติม

- **ล้างฟอร์มโดยไม่ใช้ JavaScript** หลังเพิ่ม task สำเร็จ server จะส่งฟอร์มว่างที่มี `autofocus` กลับมา แล้ว Turbo จะ focus ช่องกรอกให้เอง
- **กรอกข้อมูลไม่ถูกต้อง** server ตอบ HTTP 422 แล้ว Turbo จะแสดงฟอร์มพร้อมข้อความ error
- **ตัวกรองเป็นโค้ดฝั่ง browser ตัวเดียว** เพราะการกรองไม่ต้องใช้ข้อมูลจาก server จึงทำด้วย Stimulus แถวที่เข้ามาทีหลังผ่าน Turbo Stream หรือ broadcast จะถูกกรองตามตัวเลือกปัจจุบันเองผ่าน `itemTargetConnected`

## โครงสร้างโปรเจกต์

```
app/
├── controllers/tasks_controller.rb      # index, create, edit, update, destroy
├── models/task.rb                       # enum สถานะ, scope, broadcast
├── helpers/tasks_helper.rb              # task_counts สำหรับตัวเลขสถิติ
├── javascript/controllers/
│   └── task_filter_controller.js        # Stimulus controller ตัวเดียวของแอป
└── views/
    ├── shared/_form_errors.html.erb
    └── tasks/
        ├── index.html.erb               # หน้าหลัก + turbo_stream_from "tasks"
        ├── _task.html.erb               # แถวของ task อยู่ใน Turbo Frame
        ├── _stats.html.erb              # Total / Todo / Done
        ├── _form.html.erb               # ฟอร์มเพิ่ม task
        ├── _edit_form.html.erb          # ฟอร์มแก้ชื่อในแถว
        ├── edit.html.erb
        └── *.turbo_stream.erb           # response ของ create / update / destroy
```

## ตรวจคุณภาพโค้ด

```bash
docker compose exec web bin/rubocop       # ตรวจรูปแบบโค้ด Ruby (rubocop-rails-omakase)
docker compose exec web bin/brakeman      # ตรวจช่องโหว่ด้านความปลอดภัย
```

ไม่มีการ commit secret ขึ้น repo ไฟล์ `config/master.key` และ `.env*` อยู่ใน `.gitignore` ให้ส่งค่า secret ผ่าน environment variable
