FROM python:3.13.3


WORKDIR /code


COPY ./requirements.txt /code/requirements.txt


RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt


COPY ./app /code/app


CMD ["uvicorn", "app.infrastructure.web.fastapi.main:app", "--host", "0.0.0.0", "--port", "80", "--reload", "--reload-dir", "/code/app"]