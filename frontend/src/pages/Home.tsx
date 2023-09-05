function HomePage() {
  return (<>
    <div className="bg-red-800 w-full h-96 relative mb-4">
      <img src="/placeholder.png" alt="Cover" width="100%" height="24rem" className="w-full h-96 object-cover" />
      <h1 className="font-black font-sans text-5xl text-white absolute text-center left-28 top-36">Plan your class schedule</h1>
      <button><a href="/scheduleBuilder" className="absolute left-72 top-52 text-xl font-bold font-sans bg-red-800 p-3">Plan Schedule</a></button>
    </div>
    <div className='w-full h-96 relative mb-4 p-10 flex items-center justify-center'>
      <div className='w-[750px] flex items-center justify-center'>
        <img src="/placeholder.png" alt="feature1" className="w-72 h-72 object-cover" />
        <div className='w-10'></div>
        <div className='m-5 w-full'>
          <h2 className='text-3xl font-bold'>See your schedule on a calendar</h2>
          <p>Plan your classes in a visual way without having to guess with CRNs</p>
        </div>
      </div>
    </div>
    <div className='w-full h-96 relative mb-4 p-10 flex items-center justify-center'>
      <div className='w-[750px] flex items-center justify-center'>
        <div className='m-5'>
          <h2 className='text-3xl font-bold'>Future Feature: Generate a schedule plan</h2>
          <p>Plug in what classes you want, and get back every possible way those classes can fit together without overlap</p>
        </div>
        <div className='w-10'></div>
        <img src="/placeholder.png" alt="feature2" className="w-72 h-72 object-cover" />
      </div>
    </div>
    <div className='w-full h-96 relative mb-4 p-10 flex items-center justify-center'>
      <div className='w-[750px] flex items-center justify-center'>
        <img src="/placeholder.png" alt="feature3" className="w-72 h-72 object-cover" />
        <div className='w-10'></div>
        <div className='m-5'>
          <h2 className='text-3xl font-bold'>Future Feature: Directions</h2>
          <p>See how to get from one class to another on a map of campus, letting you know if you'll have enough time between classes</p>
        </div>
      </div>
    </div>
  </>)
}

export default HomePage;