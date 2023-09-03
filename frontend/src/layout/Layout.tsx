import Disclaimer from "./Disclaimer";
import Footer from "./Footer";
import NavBar from "./NavBar";

function Layout(props: any) {
  return (<>
    <div className="min-h-full grid grid-rows-[1fr_auto]">
      <div className="min-h-full h-full w-full mb-4 row-start-1 row-end-2">
        <div style={{'gridTemplateAreas':'"nav" "disclaimer" "content"'}} className='grid grid-rows-[auto_auto_1fr] min-h-full'>
          <div style={{'gridArea':'nav'}}><NavBar/></div>
          <div style={{'gridArea':'disclaimer'}}><Disclaimer/></div>
          <div style={{'gridArea':'content'}} className='min-h-full'>
            {props.children}
          </div>
        </div>
      </div>
      <Footer />
    </div>
  </>)
}

export default Layout