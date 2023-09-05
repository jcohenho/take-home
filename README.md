# 🖥️ Clerk Rails API

## Setup instructions

The Clerk Rails API can be run via [docker compose](https://docs.docker.com/compose/install/).

From the project's root directory, run:

`$ docker compose up`

Next, run the following commands in a separate terminal to create and prepare the database:

`$ docker compose run --rm web rake db:create`

`$ docker compose run --rm web rake db:migrate`

## How to use

To populate the database, make a `POST` request to `http://localhost:3000/api/users/populate`

To retrieve user data via cursor pagination, make a `GET` request to `http://localhost:3000/api/users/clerks`

Optional params are:

- **limit**
- **starting_after**
- **ending_before**
- **email**

See the [exercise specs](https://github.com/hatchways-community/0afea290653f4f90a494c37db9874358/blob/dev/docs/README.md) for more details on these params.

### Sample request

`GET http://localhost:3000/api/users/clerks?starting_after=274&ending_before=953`

The request above will return users that registered after the user with ID 274 and before the user with ID 953.

The users in question:

```json
{
  "id": 274,
  "first_name": "Francisco",
  "last_name": "Leyva",
  "email": "francisco.leyva@example.com",
  "phone_number": "(667) 656 1977",
  "picture": "https://randomuser.me/api/portraits/thumb/men/8.jpg",
  "registered_at": "2022-05-07T17:53:02.022Z",
  "created_at": "2023-09-05T18:18:12.489Z",
  "updated_at": "2023-09-05T18:18:12.489Z"
}
```

```json
{
  "id": 953,
  "first_name": "Zoe",
  "last_name": "Willis",
  "email": "zoe.willis@example.com",
  "phone_number": "016973 12472",
  "picture": "https://randomuser.me/api/portraits/thumb/women/3.jpg",
  "registered_at": "2022-05-17T00:35:17.049Z",
  "created_at": "2023-09-05T18:18:16.539Z",
  "updated_at": "2023-09-05T18:18:16.539Z"
}
```

### Sample response

```json
[
  {
    "id": 4711,
    "first_name": "رادین",
    "last_name": "علیزاده",
    "email": "rdyn.aalyzdh@example.com",
    "phone_number": "041-84883384",
    "picture": "https://randomuser.me/api/portraits/thumb/men/21.jpg",
    "registered_at": "2022-05-13T21:01:17.544Z",
    "created_at": "2023-09-05T18:18:37.740Z",
    "updated_at": "2023-09-05T18:18:37.740Z"
  },
  {
    "id": 576,
    "first_name": "Arjun",
    "last_name": "Shroff",
    "email": "arjun.shroff@example.com",
    "phone_number": "8778719710",
    "picture": "https://randomuser.me/api/portraits/thumb/men/18.jpg",
    "registered_at": "2022-05-12T00:36:47.552Z",
    "created_at": "2023-09-05T18:18:14.262Z",
    "updated_at": "2023-09-05T18:18:14.262Z"
  },
  {
    "id": 4162,
    "first_name": "Stach",
    "last_name": "Van Hoof",
    "email": "stach.vanhoof@example.com",
    "phone_number": "(0512) 643071",
    "picture": "https://randomuser.me/api/portraits/thumb/men/64.jpg",
    "registered_at": "2022-05-09T06:09:24.590Z",
    "created_at": "2023-09-05T18:18:34.631Z",
    "updated_at": "2023-09-05T18:18:34.631Z"
  }
]
```

## Testing

The tests use the [Rspec](https://rspec.info/) framework. The following command will run the test suite:

`$ docker compose run --rm web rspec spec`

# Overview

## Code styling and formatting

I use [Rubocop](https://github.com/rubocop/rubocop) to enforce styling and formatting. I use VSCode as my IDE and have it configured to autoformat and lint on save. It's also a good idea to configure your CI/CD to auto lint and format but due to time constraints I wasn't able to add this.

Out of scope: CI/CD configuration

## Project structure and architecture

### Routes

The `POST /populate` and `GET /clerks` endpoints are configured in the [routes](https://github.com/hatchways-community/0afea290653f4f90a494c37db9874358/blob/dev/config/routes.rb) file and defined inside the [users_controller](https://github.com/hatchways-community/0afea290653f4f90a494c37db9874358/blob/dev/app/controllers/api/users_controller.rb). I namespaced the routes under `/api/users` to make it clear that these were API endpoints related to the User model. It's a good idea in general to separate the concerns of different parts of the application and avoid potential route conflicts (e.g. `/clerks` might also be a separate index route with a frontend).

Out of scope: API Versioning

### Design Patterns

I used the Service Object pattern to encapsulate the business logic for external API data fetching and cursor pagination/filtering. Along with adhering to the Single Responsibility Principle, this pattern helps keep the controller actions skinny, reduces coupling, and makes the code more maintainable and testable.

[Here](https://github.com/hatchways-community/0afea290653f4f90a494c37db9874358/blob/dev/app/services/random_user_request.rb) is the service object for fetching data from randomuser.me.

[Here](https://github.com/hatchways-community/0afea290653f4f90a494c37db9874358/blob/dev/app/services/cursor.rb) is the service object for cursor pagination.

Out of scope:

- Unit tests for the service objects
- Decoupling the User relation from the cursor pagination logic
- Mocking HTTP requests to the randomuser.me API for deterministic tests using something like [VCR](https://github.com/vcr/vcr)

### Cursor Pagination logic

In this exercise, the spec asks us to sort by most recent registration date. Sorting is an important factor for cursor pagination, and if we're sorting by a field that's non-unique, we could potentially be skipping records as we move to the next page. After some preliminary testing, I determined that registration date was indeed unique, making the implementation straight forward. You just need to remember the last registration date and find all records before or after that date. If however, I made an incorrect assumption and registration date was _not_ truly unique, I'd need to handle that edge case. Instead of sorting by registration date alone, I'd need to add a secondary sort column with a unqiue identifier (Rails' autoincremented primary key column works for this), and then remember both the last value and the last unique id. I'd also make sure to add an index on registration date and id to ensure the query is performant.

Out of scope:

- More in-depth testing to determine registration_date uniqueness
- Implementing cursor pagination logic around a second unique column

### Populate endpoint behavior

The specs around the `/populate` endpoint were ambiguous, so I went with an approach I thought would be best in terms of user/developer experience. The specs require the ingestion of 5000 users at a time. When calling the `/populate` endpoint, adding that many rows to the database can take quite some time, and it would be a poor user experience to let the user wait that long before receiving a response. I opted for moving the ingestion logic to a background worker to run in a separate process. This way, the user would receive immediate feedback - a 200 status while data creation happens in the background. From there, I would send the user a notification once the job has completed. Notifications were out of scope for this exercise and would require some form of user identification/auth for the requester. Furthermore, the current background job implementation uses ActiveJob's [default in-memory queue](https://edgeguides.rubyonrails.org/active_job_basics.html#job-execution). This isn't suitable for production, as you'd lose jobs if the process crashes or the machine restarts. I'd opt for a 3rd party tool for job persistance, like [Sidekiq](https://github.com/sidekiq/sidekiq), which uses [Redis](https://redis.io/) to enqueue and store jobs.

Out of scope:

- Notifications for job completion/failure
- User auth
- ActiveJob persistant backend config with [Sidekiq](https://github.com/sidekiq/sidekiq)
