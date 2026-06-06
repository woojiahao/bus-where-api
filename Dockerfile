FROM elixir:1.20

WORKDIR /app

COPY . .

ENV MIX_ENV=prod

RUN mix deps.get --only ${MIX_ENV}
RUN mix deps.compile

EXPOSE 4000
CMD ["mix", "phx.server"]

