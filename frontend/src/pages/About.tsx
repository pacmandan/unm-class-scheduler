function AboutPage() {
  return (<div className='w-full h-full pl-8 pr-8 pt-2 pb-2 max-w-4xl'>
    <h1 className="text-2xl font-bold mb-5">About this application</h1>
    <p className='pt-2 pb-2'>
      It's said in the disclaimer, but I'll say it again here - <b>this site is not affiliated with UNM</b>,
      nor will it actualy schedule your classes. If you want to actually schedule your UNM classes, I recommend actually going to UNM's website.
      Unfortunately, I can't link you directly, since it's been like a decade since I went there and things have dramatically changed since then.
    </p>
    <p className='pt-2 pb-2'>
      This application originated from my time at UNM as a final project for a CS class. I was fed up with
      how their scheduling system worked - I had to type CRNs directly into a form, their search page
      wasn't very good, and overall it was hard to tell if I'd double-booked my time. I once accidentally
      signed up for a lab on a different campus since their system didn't make that kind of mistake obvious.
    </p>
    <p className='pt-2 pb-2'>
      So I'd draw everything out on a piece of paper, sketching out time slots and filling them in as I
      decided on classes. Once I had my CRNs, I'd just plug those in to sign up for classes.
    </p>
    <p className='pt-2 pb-2'>
      About a decade later, I'm now re-using the concept from that final project as coding practice.
    </p>

    <br />

    <h2 className='text-xl font-bold'>FAQ</h2>
    <h3 className='text-lg font-bold mt-4'>So how <i>do</i> I sign up for classes at UNM?</h3>
    <p className='pt-2 pb-2'>
      I'm the wrong person to ask - go ask someone working there, or check around on their website.
    </p>

    <h3 className='text-lg font-bold mt-4'>If you're not affiliated with UNM, where is the class data coming from?</h3>
    <p className='pt-2 pb-2'>
      UNM publishes up-to-date class schedule data <a className='underline' href='https://xmlschedule.unm.edu/'>here</a>,
      which is publically available for download. This appliction pulls that schedule data daily.
    </p>

    <h3 className='text-lg font-bold mt-4'>Can I see the code?</h3>
    <p className='pt-2 pb-2'>
      Sure! It's published <a className='underline' href='https://github.com/pacmandan/unm-class-scheduler'>publically on github</a>.
    </p>

    <h3 className='text-lg font-bold mt-4'>Hey, this site doesn't work very well on mobile!</h3>
    <p className='pt-2 pb-2'>
      I know. I'm more of a backend dev than a frontend one. Fixing the design and the CSS and the whatnot to work on
      mobile wasn't in the initial scope. (It was more "try and re-learn Typescript".) Fixing the frontend to
      better work on smaller screens is something I might eventually get around to.
    </p>
    <p className='pt-2 pb-2'>
      Also that's not really a question...
    </p>

    <h3 className='text-lg font-bold mt-4'>I found a bug! / I have an idea for a feature!</h3>
    <p className='pt-2 pb-2'>
      Still not a question, but that's okay.
    </p>
    <p className='pt-2 pb-2'>
      If you happen to find a bug or have a feature suggestion, I guess leave a comment or something on the repo.
      I may or may not get around to fixing it, as I'm only one guy juggling work, life, and personal project stuff.
    </p>
    <p className='pt-2 pb-2'>
      That's not to say I don't have plans! There are some features I'd like to eventually add, but I won't be actively
      working on them in the immediate future. We'll see if/when they get added.
    </p>
  </div>)
}

export default AboutPage;