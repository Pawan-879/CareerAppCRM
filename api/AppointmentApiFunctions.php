<?php

/**
 * Copy this trait into the backend and add `use AppointmentApiFunctions;`
 * inside the existing Api controller, or copy the method itself into that
 * controller. Endpoint: GET /Api/getStaffAppointments?staff_id=123
 */
trait AppointmentApiFunctions
{
    public function getStaffAppointments()
    {
        $staffId = filter_var(
            $this->request->getGet('staff_id'),
            FILTER_VALIDATE_INT
        );

        if (!$staffId || $staffId < 1) {
            return $this->response
                ->setStatusCode(400)
                ->setJSON([
                    'success' => false,
                    'message' => 'A valid staff_id is required',
                ]);
        }

        try {
            $db = db_connect();
            $appointments = $db->table('parent_appointments')
                ->select([
                    'id',
                    'student_name',
                    'father_name',
                    'contact_no',
                    'contact_no2',
                    'email',
                    'class',
                    'course',
                    'interested',
                    'appointment_type',
                    'visit_date',
                    'dropping_date',
                    'time_slot',
                    'status',
                    'visit_status',
                    'createdAt',
                ])
                ->where('staff_id', $staffId)
                ->where('status !=', 'deleted')
                ->orderBy('id', 'DESC')
                ->limit(200)
                ->get()
                ->getResultArray();

            return $this->response->setJSON([
                'success' => true,
                'data' => $appointments,
            ]);
        } catch (\Throwable $e) {
            log_message('error', 'getStaffAppointments failed: ' . $e->getMessage());

            return $this->response
                ->setStatusCode(500)
                ->setJSON([
                    'success' => false,
                    'message' => 'Unable to load appointments',
                ]);
        }
    }
}
