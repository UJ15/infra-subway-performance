import http from 'k6/http';
import { check, group, sleep, fail } from 'k6';

export let options = {
  stages: [
    { duration: '3m', target: 30 },
    { duration: '2m', target: 30 },
    { duration: '3m', target: 60 },
    { duration: '2m', target: 60 },
    { duration: '3m', target: 120 },
    { duration: '2m', target: 120 },
    { duration: '3m', target: 200 },
    { duration: '2m', target: 200 },
    { duration: '10m', target: 300 },
  ],
  thresholds: {
    http_req_duration: ['avg<100', 'p(95)<100', 'p(99)<100'],
  },
};

const BASE_URL = 'https://haservi.r-e.kr/';

export default function () {
  main();

  pathFinderPage();
  pathFind();

  sleep(1);
}

function main() {
  let response = http.get(`${BASE_URL}`);

  check(response, {
    '메인 페이지 접근': (resp) => resp.status === 200,
  });
}

function pathFinderPage() {
  let path = http.get(BASE_URL + '/path');
  check(path, {
    '경로 조회 검색 페이지 접근': (resp) => resp.status === 200,
  });
}

function pathFind() {
  let pathFind = http.get(BASE_URL + '/path?source=2&target=6');
  check(pathFind, {
    '경로 조회 검색 성공': (resp) => resp.status === 200,
  });
}