import { formatTime } from "./utils";

test('correctly formats time that has seconds', () => {
  expect(formatTime("10:32:15")).toBe("10:32 AM")
})

test('correctly formats time without seconds', () => {
  expect(formatTime("1530")).toBe("3:30 PM")
})