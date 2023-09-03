function HomePage() {
  return (<>
    <div className="bg-red-800 w-full h-96 relative mb-4">
      <img src="/placeholder.png" alt="Cover" width="100%" height="24rem" className="w-full h-96 object-cover" />
      <p className="font-black font-sans text-5xl text-white absolute text-center left-28 top-36">Plan your class schedule</p>
      <a href="/scheduleBuilder" className="absolute left-72 top-52 text-xl font-bold font-sans bg-red-800 p-3">Build Schedule</a>
    </div>
  </>)
}

export default HomePage;