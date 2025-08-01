# **betterslcm**

### **Info**

- **Version**: 0.1.0

---

### **Paths**

### /

**GET**

**Summary**: Redirect

**[ Responses ]**

code: 200

description: Successful Response

- application/json:

### /status

**GET**

**Summary**: Status

**[ Responses ]**

code: 200

description: Successful Response

- application/json:

### /login

**POST**

**Summary**: Login

**[ Request Body ]** \*

- application/json:

  - $schema: Credentials

**Example Value**:

```json
{
    "username" : string,
    "password" : string
}
```

**[ Responses ]**

code: 200

description: Successful Response

- application/json:

code: 422

description: Validation Error

- application/json:

  - $schema: HTTPValidationError

**Example Value**:

```json
{
    "detail" : [
        {
            "loc" : [
            ],
            "msg" : string,
            "type" : string
        }
    ]
}
```

### /attendance

**GET**

**Summary**: Attendance

**[ Responses ]**

code: 200

description: Successful Response

- application/json:

### /cgpa

**GET**

**Summary**: Cgpa

**[ Responses ]**

code: 200

description: Successful Response

- application/json:

### /grades

**GET**

**Summary**: Grades

**[ Parameters ]**

| name     |  in   | description |  type   | required |
| :------- | :---: | :---------- | :-----: | :------: |
| semester | query |             | integer |    \*    |

**[ Responses ]**

code: 200

description: Successful Response

- application/json:

code: 422

description: Validation Error

- application/json:

  - $schema: HTTPValidationError

**Example Value**:

```json
{
    "detail" : [
        {
            "loc" : [
            ],
            "msg" : string,
            "type" : string
        }
    ]
}
```

### /internal_marks

**GET**

**Summary**: Internal Marks

**[ Parameters ]**

| name     |  in   | description |  type   | required |
| :------- | :---: | :---------- | :-----: | :------: |
| semester | query |             | integer |    \*    |

**[ Responses ]**

code: 200

description: Successful Response

- application/json:

code: 422

description: Validation Error

- application/json:

  - $schema: HTTPValidationError

**Example Value**:

```json
{
    "detail" : [
        {
            "loc" : [
            ],
            "msg" : string,
            "type" : string
        }
    ]
}
```

---

### **Components**

### Schemas

**Credentials**

**username**:

- **string**

  - _required: true_

  - _nullable: false_

**password**:

- **string**

  - _required: true_

  - _nullable: false_

**HTTPValidationError**

**detail**:

- **array [ ValidationError ]**

  - _required: false_

  - _nullable: false_

**ValidationError**

**loc**:

    - _required: true_

    - _nullable: false_

**msg**:

- **string**

  - _required: true_

  - _nullable: false_

**type**:

- **string**

  - _required: true_

  - _nullable: false_

---
