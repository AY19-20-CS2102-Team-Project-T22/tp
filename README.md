## Environment
* NodeJS (backend)
* ReactJS (frontend)
* PostgreSQL (database)

## Configuration (Ubuntu)

*backend: localhost:5000*
*frontend: localhost:3000*

### 1. Modify .env file in backend to specify your database:
```
DB_USER=xxxxx
DB_PASS=password
DB_NAME=fds
DB_HOST=localhost
DB_PORT=5432
```

### 2. Install NodeJS, yarn and npm

### 3. run configure.sh
```bash
cd backend
npm install
cd ..
cd frontend/react-fds
yarn install
```

## Run

### Backend

```bash
cd backend & node index.js
```

### Frontend

```bash
cd frontend/react-fds & yarn start
```

**After setting up backend and frontend, visit http://localhost:3000 to see FDS website**
