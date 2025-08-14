# 🧠 MLP Accelerator on FPGA
> 디지털 시스템 설계 프로젝트 – 4-계층 MLP 추론을 위한 스트림 기반 FPGA 가속기  
> 고정소수점 기반 병렬 MAC 구조 및 계층별 파이프라인으로 저지연 추론 실현

---

## 📌 목차

1. 프로젝트 개요  
2. 시스템 아키텍처  
3. 주요 설계 요소  
4. 하드웨어 구성 및 환경  
5. 테스트 및 검증 방법  
6. 결과 요약  
7. 참고 자료  

---

## 1. 프로젝트 개요

- **과목명**: 디지털 시스템 설계 (2025년 1학기)
- **목표**:  
  - Zynq-7000 기반 FPGA 상에서 4-layer MLP 모델을 고속/저지연으로 추론하는 전용 하드웨어 구현  
  - 성능 우선 설계 원칙에 따라 연산 자원을 적극 활용하여 병목 없는 파이프라인 구성
- **주요 특징**:
  - Q8.8 고정소수점 연산 (DSP 최적화)
  - 각 레이어별 연산 유닛(PU) 수 조정으로 파이프라인 균형 확보
  - Valid/Ready 기반 Handshaking 프로토콜 도입
  - 하위 모듈 기반 Bottom-Up 설계 + 온보드 검증

---

## 2. 시스템 아키텍처

- 전체 구성도 삽입 위치:

  `![Block Diagram](docs/block_diagram.png)`

- 데이터 흐름 요약:
  1. **입력**: 784차원 정규화된 정수 벡터 (1 sample)
  2. **연산 경로**:  
     Layer1 (784→64) → Layer2 (64→256) → Layer3 (256→128) → Layer4 (128→10)
  3. **출력**: 10개 클래스에 대한 로짓값
  4. **제어 흐름**: FSM 기반 Global Controller가 동기 제어

---

## 3. 주요 설계 요소

| 항목              | 내용 |
|-------------------|------|
| 연산 형식         | Q8.8 고정소수점 (16-bit) |
| 활성화 함수       | ReLU (조건 연산자 기반 구현) |
| 각 Layer 구조     | Fully Connected + 병렬 PU + Adder Tree |
| 파이프라인 구조   | 각 Layer 독립 FSM + Streamlined 연산 흐름 |
| 통신 프로토콜     | Valid/Ready 기반 Handshaking |
| 컨트롤 구조       | Global FSM + Local FSM per Layer |
| 입력 정규화 방식  | Zero-extension (Verilog 내 정수 기반 scaling) |

---

## 4. 하드웨어 구성 및 환경

| 항목            | 사양 |
|-----------------|------|
| FPGA Platform   | Xilinx Zynq-7000 (ZC702) |
| Target Freq     | 125 MHz |
| 리소스 활용     | DSP 92.27%, BRAM 48.93%, LUT 32.65% |

### 🔧 각 레이어별 연산 구조 및 데이터 흐름

---

### 🔹 Layer 1: 784 × 64 Fully Connected Layer

- 입력 차원: 784  
- 출력 뉴런: 64  
- 총 연산량: 50,176 MAC  
- DSP 사용량: 98개  
- 구조:  
  - 98개의 DSP를 활용하여 병렬 MAC 연산  
  - 하나의 출력 뉴런 계산에 8클럭 × 8회 반복 수행  
  - 결과는 Adder Tree를 통해 누산 후 Buffer 저장
- Cycle 수: 약 584 cycles (`512 + 64 + control margin`)

**📷 그림 삽입 위치:**  
`![Layer 1 Dataflow](docs/layer1_dataflow.png)`

---

### 🔹 Layer 2: 64 × 256 Fully Connected Layer

- 입력 차원: 64  
- 출력 뉴런: 256  
- 총 연산량: 16,384 MAC  
- DSP 사용량: 32개  
- 구조:  
  - 32개의 PU를 활용하여 64 cycle 연산을 8회 반복  
  - 각 cycle에서 8개의 뉴런 계산 병렬 수행
- Cycle 수: 약 528 cycles

**📷 그림 삽입 위치:**  
`![Layer 2 Dataflow](docs/layer2_dataflow.png)`

---

### 🔹 Layer 3: 256 × 128 Fully Connected Layer

- 입력 차원: 256  
- 출력 뉴런: 128  
- 총 연산량: 32,768 MAC  
- DSP 사용량: 64개  
- 구조:  
  - Layer 2와 동일한 연산 구조  
  - 입력, 출력 차원만 변경됨
- Cycle 수: 약 516 cycles

**📷 그림 삽입 위치:**  
`![Layer 3 Dataflow](docs/layer3_dataflow.png)`

---

### 🔹 Layer 4: 128 × 10 Fully Connected Layer

- 입력 차원: 128  
- 출력 뉴런: 10  
- 총 연산량: 1,280 MAC  
- DSP 사용량: 10개  
- 구조:  
  - 각 출력 뉴런에 1개의 전용 PU 할당  
  - 전 뉴런 병렬 계산 방식
- Cycle 수: 약 128 cycles

**📷 그림 삽입 위치:**  
`![Layer 4 Dataflow](docs/layer4_dataflow.png)`

---

## 5. 테스트 및 검증 방법

- **Simulation 단계**:  
  - 각 모듈 단위로 testbench 작성 (PE, Controller, Buffer 등)
  - Python reference 연산값과 시뮬레이션 결과 비교

- **On-Board 단계**:  
  - DMA 송신을 통해 입력 전송 → 연산 → 출력 수신
  - ILA 삽입 후 각 레이어별 ready/valid 흐름 검증
  - I/O 모두 `.txt` 파일 기반 처리

---

## 6. 결과 요약

| 항목            | 수치 / 내용 |
|-----------------|-------------|
| 총 Latency      | 1756 cycles |
| Throughput      | 약 71,206 samples/sec (125 MHz 기준) |
| DSP 사용량      | 204 / 220 (92.27%) |
| 정확도          | Python 시뮬레이터와 결과 일치 확인 |
| 문제 해결 경험  | On-board output all-zero → ILA 분석으로 FSM 오류 수정 |
| 최적화 전략     | Layer 간 연산량 고려한 PU 수 비례 분배 → 병목 최소화 |

---

## 7. 참고 자료

- Xilinx UG901 – *Vivado Design Suite User Guide*  
- Digital System Design 강의자료 (2025, 팀 2 조수환 외)  
- Dong et al., *Understanding DSP48 for Parallel MAC*
