from fastapi import FastAPI

app = FastAPI()


# Health check for the container: uvicorn serves this app (see Dockerfile).
@app.get("/")
def root():
    return {"status": "ok"}
