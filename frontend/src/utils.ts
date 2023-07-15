const formatTimeSeconds = (time: string) => {
  return formatTimeNumber(time.split(":").slice(0,2).join(""));
}

const formatTimeNumber = (time: string) => {
  // Time string format is "HHMM" in 24hr format. I want to return "HH:MM AM/PM" (12hr format).
  // JS only does full Date objects, not just Time, so "Fine. I guess I'll do it myself."
  let hh24 = parseInt(time.slice(0,2));
  let mm = time.slice(2,4);
  // I doubt we'll ever have any midnight classes,
  // and if there are, it'll probably be 0000, not 2400,
  // but just in case, mod24 this.
  let ampm = hh24 % 24 >= 12 ? "PM" : "AM";
  // Javascript modulo isn't actually a modulo (it's a remainder), and we want a range from 1 - 12, not 0 - 12.
  // Hence the convoluted weirdness here.
  let hh12 = ((hh24 - 1) % 12 + 12) % 12 + 1;
  // Leaving this here in case I want to pad the hour.
  // let hh = hh12 < 10 ? hh12.toString().padStart(2, '0') : hh12.toString();
  let hh = hh12.toString();
  return `${hh}:${mm} ${ampm}`
}

// TODO: Clean this up to handle both "HHMM" and "HH:MM:SS".
// This is a bit of a mess.
export const formatTime = (time: string) => {
  if (!time) {
    return null
  }

  if(time.match(/[0-9][0-9][0-9][0-9]/)) {
    return formatTimeNumber(time)
  } else if(time.match(/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/)) {
    return formatTimeSeconds(time)
  } else {
    return time
  }
}